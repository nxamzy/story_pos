import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocam_pos/core/network/exceptions.dart';
import 'package:ocam_pos/core/network/firestore_paths.dart';
import 'package:ocam_pos/data/models/purchase_model.dart';

abstract class PurchaseRemoteDataSource {
  Stream<List<PurchaseModel>> watchPurchases({int limit});

  /// Xaridni yozadi: ombor qoldig'i oshadi, mahsulot tannarxi yangilanadi
  /// va kassadan to'langan bo'lsa kassa balansi kamayadi — bitta
  /// tranzaksiyada.
  Future<String> createPurchase(PurchaseModel purchase);
}

class PurchaseRemoteDataSourceImpl implements PurchaseRemoteDataSource {
  final FirestorePaths _paths;

  PurchaseRemoteDataSourceImpl({required FirestorePaths paths})
    : _paths = paths;

  @override
  Stream<List<PurchaseModel>> watchPurchases({int limit = 50}) => _paths
      .purchases
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((doc) => PurchaseModel.fromMap(doc.data(), doc.id))
            .toList(),
      );

  @override
  Future<String> createPurchase(PurchaseModel purchase) async {
    if (purchase.items.isEmpty) {
      throw const ValidationException("Mahsulot qo'shilmagan");
    }
    if (purchase.items.any((item) => item.quantity <= 0)) {
      throw const ValidationException("Miqdor 0 dan katta bo'lishi kerak");
    }

    final doc = _paths.purchases.doc();
    final drawerRef = _paths.drawer;

    await _paths.db.runTransaction((transaction) async {
      // 1-qadam: barcha o'qishlar.
      final productSnaps = <String, DocumentSnapshot<Map<String, dynamic>>>{};
      for (final item in purchase.items) {
        if (item.productId.isEmpty ||
            productSnaps.containsKey(item.productId)) {
          continue;
        }
        productSnaps[item.productId] = await transaction.get(
          _paths.products.doc(item.productId),
        );
      }

      final drawerSnap = purchase.paidFromDrawer
          ? await transaction.get(drawerRef)
          : null;

      // 2-qadam: tekshiruvlar.
      for (final item in purchase.items) {
        final snap = productSnaps[item.productId];
        if (snap == null || !snap.exists) {
          throw ValidationException(
            "«${item.name}» ombordan topilmadi — u o'chirilgan bo'lishi mumkin",
          );
        }
      }

      if (purchase.paidFromDrawer) {
        final balance =
            (drawerSnap?.data()?['current_balance'] as num?)?.toDouble() ?? 0;
        if (balance < purchase.total) {
          throw const ValidationException("Kassada yetarli mablag' yo'q");
        }
      }

      // 3-qadam: yozish.
      for (final item in purchase.items) {
        transaction.update(_paths.products.doc(item.productId), {
          'stock': FieldValue.increment(item.quantity),
          // Tannarx oxirgi xariddagi narxga yangilanadi — foyda hisobi shu
          // qiymatga tayanadi.
          'buyPrice': item.buyPrice,
        });
      }

      if (purchase.paidFromDrawer) {
        transaction.update(drawerRef, {
          'current_balance': FieldValue.increment(-purchase.total),
        });
      }

      transaction.set(doc, {
        ...purchase.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    return doc.id;
  }
}
