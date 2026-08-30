import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocam_pos/core/network/exceptions.dart';
import 'package:ocam_pos/core/network/firestore_paths.dart';
import 'package:ocam_pos/data/models/employee_model.dart';
import 'package:ocam_pos/data/models/transfer_log_model.dart';

abstract class EmployeeRemoteDataSource {
  Stream<List<EmployeeModel>> watchEmployees();
  Future<String> addEmployee(EmployeeModel employee);
  Future<void> updateEmployee(EmployeeModel employee);
  Future<void> deleteEmployee(String id);

  Stream<double> watchDrawerBalance();
  Stream<List<TransferLogModel>> watchTransferLogs({int limit});
  Future<void> transferBalance({
    required EmployeeModel from,
    required EmployeeModel to,
    required double amount,
    required String note,
  });
}

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  final FirestorePaths _paths;

  EmployeeRemoteDataSourceImpl({required FirestorePaths paths})
    : _paths = paths;

  @override
  Stream<List<EmployeeModel>> watchEmployees() => _paths.employees
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((doc) => EmployeeModel.fromMap(doc.data(), doc.id))
            .toList(),
      );

  @override
  Future<String> addEmployee(EmployeeModel employee) async {
    final doc = employee.id.isEmpty
        ? _paths.employees.doc()
        : _paths.employees.doc(employee.id);
    await doc.set({
      ...employee.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return doc.id;
  }

  @override
  Future<void> updateEmployee(EmployeeModel employee) =>
      _paths.employees.doc(employee.id).update(employee.toMap());

  @override
  Future<void> deleteEmployee(String id) => _paths.employees.doc(id).delete();

  @override
  Stream<double> watchDrawerBalance() => _paths.drawer.snapshots().map(
    (doc) => (doc.data()?['current_balance'] as num?)?.toDouble() ?? 0,
  );

  @override
  Stream<List<TransferLogModel>> watchTransferLogs({int limit = 50}) =>
      _paths.transferLogs
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .snapshots()
          .map(
            (snap) => snap.docs
                .map((doc) => TransferLogModel.fromMap(doc.data(), doc.id))
                .toList(),
          );

  @override
  Future<void> transferBalance({
    required EmployeeModel from,
    required EmployeeModel to,
    required double amount,
    required String note,
  }) async {
    if (amount <= 0) {
      throw const ValidationException("Summa 0 dan katta bo'lishi kerak");
    }
    if (from.id == to.id) {
      throw const ValidationException("O'ziga o'tkazma qilib bo'lmaydi");
    }

    final fromRef = _paths.employees.doc(from.id);
    final toRef = _paths.employees.doc(to.id);
    final logRef = _paths.transferLogs.doc();

    await _paths.db.runTransaction((transaction) async {
      final fromSnap = await transaction.get(fromRef);
      final toSnap = await transaction.get(toRef);

      if (!fromSnap.exists || !toSnap.exists) {
        throw const NotFoundException("Xodim topilmadi");
      }

      final fromBalance =
          (fromSnap.data()?['balance'] as num?)?.toDouble() ?? 0;
      if (fromBalance < amount) {
        throw const ValidationException("Mablag' yetarli emas");
      }

      transaction.update(fromRef, {'balance': FieldValue.increment(-amount)});
      transaction.update(toRef, {'balance': FieldValue.increment(amount)});
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
}
