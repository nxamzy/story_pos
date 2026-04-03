import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _currentUserId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Tizimga kirmagansiz!");
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _customerCol => _firestore
      .collection('users')
      .doc(_currentUserId)
      .collection('customers');

  Stream<List<CustomerModel>> getCustomersStream() {
    return _customerCol
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CustomerModel.fromMap(doc.data(), doc.id))
              .toList(),
        )
        .handleError((error) {
          print("Firestore Stream Error: $error");
          return <CustomerModel>[];
        });
  }

  Future<void> addOrUpdateCustomer(CustomerModel customer) async {
    final String docId = customer.id.isEmpty
        ? _customerCol.doc().id
        : customer.id;

    final data = customer.toMap();
    data['id'] = docId;

    await _customerCol.doc(docId).set(data, SetOptions(merge: true));
  }

  Future<void> deleteCustomer(String customerId) async {
    await _customerCol.doc(customerId).delete();
  }
}
