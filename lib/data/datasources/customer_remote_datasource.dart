import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocam_pos/core/network/firestore_paths.dart';
import 'package:ocam_pos/data/models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  Stream<List<CustomerModel>> watchCustomers();
  Future<String> addCustomer(CustomerModel customer);
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String id);
  Future<void> addSpending(String customerId, double amount);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final FirestorePaths _paths;

  CustomerRemoteDataSourceImpl({required FirestorePaths paths})
    : _paths = paths;

  @override
  Stream<List<CustomerModel>> watchCustomers() => _paths.customers
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((doc) => CustomerModel.fromMap(doc.data(), doc.id))
            .toList(),
      );

  @override
  Future<String> addCustomer(CustomerModel customer) async {
    final doc = customer.id.isEmpty
        ? _paths.customers.doc()
        : _paths.customers.doc(customer.id);

    await doc.set({
      ...customer.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return doc.id;
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) =>
      _paths.customers.doc(customer.id).update(customer.toMap());

  @override
  Future<void> deleteCustomer(String id) => _paths.customers.doc(id).delete();

  @override
  Future<void> addSpending(String customerId, double amount) =>
      _paths.customers.doc(customerId).update({
        'totalSpent': FieldValue.increment(amount),
      });
}
