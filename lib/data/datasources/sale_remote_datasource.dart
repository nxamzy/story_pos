import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocam_pos/core/network/exceptions.dart';
import 'package:ocam_pos/core/network/firestore_paths.dart';
import 'package:ocam_pos/data/models/sale_model.dart';

abstract class SaleRemoteDataSource {
  /// Savdoni yakunlaydi: sotuv yozuvi + omborni kamaytirish + kassa balansi
  /// — hammasi bitta tranzaksiyada. Biri xato bo'lsa hech biri yozilmaydi.
  Future<String> createSale(SaleModel sale);

  Stream<List<SaleModel>> watchSales({DateTime? from, DateTime? to, int? limit});
  Future<List<SaleModel>> getSales({DateTime? from, DateTime? to});

  /// Bitta mijozning barcha xaridlari, eng yangisidan boshlab.
  Future<List<SaleModel>> getSalesByCustomer(String customerId);

  /// Savdoni qaytaradi (bekor qiladi): ombor tiklanadi, naqd to'lov bo'lsa
  /// kassadan yechiladi, mijozning sarfi kamayadi — hammasi bitta
  /// tranzaksiyada.
  Future<void> refundSale(String saleId);

  /// So'nggi [days] kun ichida qaytarilgan savdolar.
  Future<List<SaleModel>> getRefundedSales({int days});
}

class SaleRemoteDataSourceImpl implements SaleRemoteDataSource {
  final FirestorePaths _paths;

  SaleRemoteDataSourceImpl({required FirestorePaths paths}) : _paths = paths;

  @override
  Future<String> createSale(SaleModel sale) async {
    if (sale.items.isEmpty) {
      throw const ValidationException("Savat bo'sh");
    }

    final saleDoc = _paths.sales.doc();
    final drawerDoc = _paths.drawer;

    await _paths.db.runTransaction((transaction) async {
      // 1-qadam: Firestore tranzaksiyasida avval BARCHA o'qish amallari.
      final productRefs = sale.items
          .where((item) => item.product.id.isNotEmpty)
          .map((item) => _paths.products.doc(item.product.id))
          .toList();

      final snapshots = <String, DocumentSnapshot<Map<String, dynamic>>>{};
      for (final ref in productRefs) {
        snapshots[ref.id] = await transaction.get(ref);
      }
      final drawerSnap = await transaction.get(drawerDoc);

      // 2-qadam: qoldiq yetarliligini tekshirish.
      for (final item in sale.items) {
        final snap = snapshots[item.product.id];
        if (snap == null || !snap.exists) continue; // o'chirilgan mahsulot

        final currentStock = (snap.data()?['stock'] as num?)?.toInt() ?? 0;
        if (currentStock < item.quantity) {
          throw ValidationException(
            "«${item.product.name}» omborda yetarli emas "
            "(qoldiq: $currentStock, kerak: ${item.quantity})",
          );
        }
      }

      // 3-qadam: yozish.
      transaction.set(saleDoc, {
        ...sale.toMap(),
        // Odatda server vaqti yoziladi (qurilma soati noto'g'ri bo'lishi
        // mumkin). Lekin kassir checkout'da boshqa kunni tanlagan bo'lsa
        // (masalan kechagi savdoni keyinroq kiritish) — o'sha sana
        // saqlanadi. Ilgari tanlangan sana e'tiborga olinmasdi: hisobotda
        // savdo har doim bugungi kunga tushardi.
        'createdAt': _isToday(sale.createdAt)
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(sale.createdAt),
      });

      for (final item in sale.items) {
        final snap = snapshots[item.product.id];
        if (snap == null || !snap.exists) continue;
        transaction.update(_paths.products.doc(item.product.id), {
          'stock': FieldValue.increment(-item.quantity),
        });
      }

      // Kassa balansi faqat naqd to'lovda oshadi.
      if (sale.paymentMethod == 'cash') {
        if (drawerSnap.exists) {
          transaction.update(drawerDoc, {
            'current_balance': FieldValue.increment(sale.total),
          });
        } else {
          transaction.set(drawerDoc, {'current_balance': sale.total});
        }
      }

      if (sale.customerId != null && sale.customerId!.isNotEmpty) {
        transaction.update(_paths.customers.doc(sale.customerId!), {
          'totalSpent': FieldValue.increment(sale.total),
        });
      }
    });

    return saleDoc.id;
  }

  @override
  Future<void> refundSale(String saleId) async {
    final saleRef = _paths.sales.doc(saleId);
    final drawerRef = _paths.drawer;

    await _paths.db.runTransaction((transaction) async {
      // 1-qadam: Firestore tranzaksiyasida avval BARCHA o'qish amallari.
      final saleSnap = await transaction.get(saleRef);
      if (!saleSnap.exists) {
        throw const NotFoundException("Savdo topilmadi");
      }

      final sale = SaleModel.fromMap(saleSnap.data()!, saleSnap.id);
      if (sale.refunded) {
        throw const ValidationException("Bu savdo allaqachon qaytarilgan");
      }

      final productSnaps = <String, DocumentSnapshot<Map<String, dynamic>>>{};
      for (final item in sale.items) {
        final id = item.product.id;
        if (id.isEmpty || productSnaps.containsKey(id)) continue;
        productSnaps[id] = await transaction.get(_paths.products.doc(id));
      }

      final isCash = sale.paymentMethod == 'cash';
      final drawerSnap = isCash ? await transaction.get(drawerRef) : null;

      // 2-qadam: naqd pul qaytariladigan bo'lsa, kassada yetarli mablag'
      // borligini tekshiramiz — aks holda kassa balansi manfiyga tushardi.
      if (isCash) {
        final balance =
            (drawerSnap?.data()?['current_balance'] as num?)?.toDouble() ?? 0;
        if (balance < sale.total) {
          throw const ValidationException(
            "Kassada yetarli mablag' yo'q — avval kassani to'ldiring",
          );
        }
      }

      // 3-qadam: yozish.
      for (final item in sale.items) {
        final snap = productSnaps[item.product.id];
        // Mahsulot o'chirilgan bo'lsa qoldiqni tiklab bo'lmaydi — savdo
        // baribir qaytarilgan deb belgilanadi.
        if (snap == null || !snap.exists) continue;
        transaction.update(_paths.products.doc(item.product.id), {
          'stock': FieldValue.increment(item.quantity),
        });
      }

      if (isCash) {
        transaction.update(drawerRef, {
          'current_balance': FieldValue.increment(-sale.total),
        });
      }

      if (sale.customerId != null && sale.customerId!.isNotEmpty) {
        transaction.update(_paths.customers.doc(sale.customerId!), {
          'totalSpent': FieldValue.increment(-sale.total),
        });
      }

      transaction.update(saleRef, {
        'refunded': true,
        'refundedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<List<SaleModel>> getRefundedSales({int days = 30}) async {
    // Faqat sana bo'yicha so'raladi va `refunded` Dart tomonida
    // filtrlanadi — shunda Firestore'da qo'shimcha kompozit indeks kerak
    // bo'lmaydi.
    final from = DateTime.now().subtract(Duration(days: days));
    final sales = await getSales(from: from);
    return sales.where((sale) => sale.refunded).toList();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Query<Map<String, dynamic>> _query({DateTime? from, DateTime? to}) {
    Query<Map<String, dynamic>> query = _paths.sales;
    if (from != null) {
      query = query.where(
        'createdAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(from),
      );
    }
    if (to != null) {
      query = query.where('createdAt', isLessThan: Timestamp.fromDate(to));
    }
    return query.orderBy('createdAt', descending: true);
  }

  @override
  Stream<List<SaleModel>> watchSales({
    DateTime? from,
    DateTime? to,
    int? limit,
  }) {
    var query = _query(from: from, to: to);
    if (limit != null) query = query.limit(limit);
    return query.snapshots().map(
      (snap) =>
          snap.docs.map((d) => SaleModel.fromMap(d.data(), d.id)).toList(),
    );
  }

  @override
  Future<List<SaleModel>> getSales({DateTime? from, DateTime? to}) async {
    final snap = await _query(from: from, to: to).get();
    return snap.docs.map((d) => SaleModel.fromMap(d.data(), d.id)).toList();
  }

  @override
  Future<List<SaleModel>> getSalesByCustomer(String customerId) async {
    // Faqat `customerId` bo'yicha filtrlanadi (compound index shart emas) —
    // saralash Dart tomonida qilinadi.
    final snap = await _paths.sales
        .where('customerId', isEqualTo: customerId)
        .get();
    final sales = snap.docs
        .map((d) => SaleModel.fromMap(d.data(), d.id))
        .toList();
    sales.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sales;
  }
}
