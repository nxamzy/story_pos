import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/supplier_model.dart';

class SupplierRepository {
  final CollectionReference _supplierCollection = FirebaseFirestore.instance
      .collection('suppliers');

  Stream<List<SupplierModel>> getSuppliers() {
    return _supplierCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SupplierModel.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> addSupplier(SupplierModel supplier) async {
    await _supplierCollection.add(supplier.toMap());
  }

  Future<void> deleteSupplier(String id) async {
    await _supplierCollection.doc(id).delete();
  }

  Future<void> updateSupplier(SupplierModel supplier) async {
    await _supplierCollection.doc(supplier.id).update(supplier.toMap());
  }
}
