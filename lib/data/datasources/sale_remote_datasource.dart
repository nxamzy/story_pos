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
        'createdAt': FieldValue.serverTimestamp(),
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
