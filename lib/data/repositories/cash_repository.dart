import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocam_pos/data/models/employee_model.dart';

abstract class CashRepository {
  Stream<double> getDrawerBalance();
  Stream<List<EmployeeModel>> getEmployees();
  Future<void> transferBalance({
    required EmployeeModel from,
    required EmployeeModel to,
    required double amount,
    required String note,
  });
  Future<void> addEmployee(EmployeeModel employee);
}

class CashRepositoryImpl implements CashRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Stream<double> getDrawerBalance() {
    return _db
        .collection('pos_settings')
        .doc('drawer_info')
        .snapshots()
        .map((doc) => (doc.data()?['current_balance'] ?? 0.0).toDouble());
  }

  @override
  Stream<List<EmployeeModel>> getEmployees() {
    return _db
        .collection('employees')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EmployeeModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Future<void> transferBalance({
    required EmployeeModel from,
    required EmployeeModel to,
    required double amount,
    required String note,
  }) async {
    final fromRef = _db.collection('employees').doc(from.id);
    final toRef = _db.collection('employees').doc(to.id);
    final logRef = _db.collection('transfer_logs').doc();

    return _db.runTransaction((transaction) async {
      final fromSnap = await transaction.get(fromRef);
      final toSnap = await transaction.get(toRef);

      if (!fromSnap.exists || !toSnap.exists) {
        throw Exception("Xodim topilmadi");
      }

      double currentFrom = (fromSnap.data()?['balance'] ?? 0.0).toDouble();
      double currentTo = (toSnap.data()?['balance'] ?? 0.0).toDouble();

      if (currentFrom < amount) throw Exception("Mablag' yetarli emas!");

      transaction.update(fromRef, {'balance': currentFrom - amount});
      transaction.update(toRef, {'balance': currentTo + amount});

      transaction.set(logRef, {
        'from_id': from.id,
        'from_name': from.name,
        'to_id': to.id,
        'to_name': to.name,
        'amount': amount,
        'note': note,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> addEmployee(EmployeeModel employee) async {
    try {
      await _db.collection('employees').doc(employee.id).set(employee.toMap());
    } catch (e) {
      throw Exception("Xodim qo'shishda xatolik yuz berdi: $e");
    }
  }
}
