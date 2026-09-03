import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocam_pos/core/network/firestore_paths.dart';
import 'package:ocam_pos/data/models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  Stream<List<CustomerModel>> watchCustomers();
  Future<String> addCustomer(CustomerModel customer);
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String id);
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
    final isNew = customer.id.isEmpty;
    final doc = isNew
        ? _paths.customers.doc()
        : _paths.customers.doc(customer.id);

    await doc.set({
      ...customer.toMap(),
      // `createdAt` faqat yangi mijoz yaratilganda yoziladi. Ilgari u har
      // saqlashda qayta yozilardi — mijozni tahrirlash uning "ro'yxatdan
      // o'tgan sana"sini bugungi kunga o'zgartirib, ro'yxatdagi tartibini
      // ham buzardi (ro'yxat createdAt bo'yicha saralanadi).
      if (isNew) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return doc.id;
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) =>
      _paths.customers.doc(customer.id).update(customer.toMap());

  // Eslatma: mijozning `totalSpent` maydoni savdo tranzaksiyasi ichida
  // (`SaleRemoteDataSourceImpl.createSale`) yangilanadi — shu sababli bu
  // yerda alohida metod yo'q.
  @override
  Future<void> deleteCustomer(String id) => _paths.customers.doc(id).delete();
}
