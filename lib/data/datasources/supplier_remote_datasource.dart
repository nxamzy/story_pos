import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocam_pos/core/network/firestore_paths.dart';
import 'package:ocam_pos/data/models/supplier_model.dart';

abstract class SupplierRemoteDataSource {
  Stream<List<SupplierModel>> watchSuppliers({DateTime? date});
  Future<String> addSupplier(SupplierModel supplier);
  Future<void> updateSupplier(SupplierModel supplier);
  Future<void> deleteSupplier(String id);
}

class SupplierRemoteDataSourceImpl implements SupplierRemoteDataSource {
  final FirestorePaths _paths;

  SupplierRemoteDataSourceImpl({required FirestorePaths paths})
    : _paths = paths;

  @override
  Stream<List<SupplierModel>> watchSuppliers({DateTime? date}) {
    Query<Map<String, dynamic>> query = _paths.suppliers;

    if (date != null) {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));
      query = query
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start),
            isLessThan: Timestamp.fromDate(end),
          );
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => SupplierModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Future<String> addSupplier(SupplierModel supplier) async {
    final doc = _paths.suppliers.doc();
    await doc.set({
      ...supplier.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  @override
  Future<void> updateSupplier(SupplierModel supplier) =>
      _paths.suppliers.doc(supplier.id).update(supplier.toMap());

  @override
  Future<void> deleteSupplier(String id) => _paths.suppliers.doc(id).delete();
}
