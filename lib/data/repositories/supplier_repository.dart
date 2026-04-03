import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/supplier_model.dart';

class SupplierRepository {
  final CollectionReference _supplierCollection = FirebaseFirestore.instance
      .collection('suppliers');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<SupplierModel>> getSuppliers({DateTime? selectedDate}) {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    Query query = _supplierCollection.where('userId', isEqualTo: uid);

    if (selectedDate != null) {
      DateTime startOfDay = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      DateTime endOfDay = startOfDay
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));

      query = query
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where(
            'createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
          );
    }

    return query.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => SupplierModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addSupplier(SupplierModel supplier) async {
    final String? uid = _auth.currentUser?.uid;

    if (uid != null) {
      final data = supplier.toMap();
      data['userId'] = uid;
      data['createdAt'] = FieldValue.serverTimestamp();

      await _supplierCollection.add(data);
    }
  }

  Future<void> deleteSupplier(String id) async {
    await _supplierCollection.doc(id).delete();
  }

  Future<void> updateSupplier(SupplierModel supplier) async {
    final data = supplier.toMap();
    data['userId'] = _auth.currentUser?.uid;

    await _supplierCollection.doc(supplier.id).update(data);
  }
}
