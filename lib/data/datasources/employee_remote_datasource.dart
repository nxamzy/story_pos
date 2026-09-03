import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocam_pos/core/network/exceptions.dart';
import 'package:ocam_pos/core/network/firestore_paths.dart';
import 'package:ocam_pos/data/models/employee_model.dart';
import 'package:ocam_pos/data/models/transfer_log_model.dart';
import 'package:ocam_pos/data/models/transfer_party_model.dart';

abstract class EmployeeRemoteDataSource {
  Stream<List<EmployeeModel>> watchEmployees();
  Future<String> addEmployee(EmployeeModel employee);
  Future<void> updateEmployee(EmployeeModel employee);
  Future<void> deleteEmployee(String id);

  Stream<double> watchDrawerBalance();
  Stream<List<TransferLogModel>> watchTransferLogs({int limit});

  /// Pulni bir tarafdan ikkinchisiga o'tkazadi. Taraf kassa ham, xodim ham
  /// bo'lishi mumkin — ikkalasi bitta tranzaksiyada yangilanadi.
  Future<void> transferBalance({
    required TransferParty from,
    required TransferParty to,
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
    final isNew = employee.id.isEmpty;
    final doc = isNew
        ? _paths.employees.doc()
        : _paths.employees.doc(employee.id);
    await doc.set({
      ...employee.toMap(),
      // Mijozdagidek: `createdAt` faqat yangi yozuvda o'rnatiladi.
      if (isNew) 'createdAt': FieldValue.serverTimestamp(),
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

  /// Tarafning Firestore hujjati: kassa — `pos_settings/drawer_info`,
  /// xodim — `employees/{id}`.
  DocumentReference<Map<String, dynamic>> _refOf(TransferParty party) =>
      party.isDrawer ? _paths.drawer : _paths.employees.doc(party.id);

  /// Balans maydoni nomi ikki hujjatda har xil.
  String _balanceFieldOf(TransferParty party) =>
      party.isDrawer ? 'current_balance' : 'balance';

  double _balanceOf(
    TransferParty party,
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) => (snap.data()?[_balanceFieldOf(party)] as num?)?.toDouble() ?? 0;

  @override
  Future<void> transferBalance({
    required TransferParty from,
    required TransferParty to,
    required double amount,
    required String note,
  }) async {
    if (amount <= 0) {
      throw const ValidationException("Summa 0 dan katta bo'lishi kerak");
    }
    if (from.id == to.id) {
      throw const ValidationException("O'ziga o'tkazma qilib bo'lmaydi");
    }

    final fromRef = _refOf(from);
    final toRef = _refOf(to);
    final logRef = _paths.transferLogs.doc();

    await _paths.db.runTransaction((transaction) async {
      final fromSnap = await transaction.get(fromRef);
      final toSnap = await transaction.get(toRef);

      // Kassa hujjati birinchi naqd savdogacha umuman mavjud bo'lmaydi —
      // bu xato emas, balansi shunchaki 0. Xodim esa mavjud bo'lishi shart.
      if (!from.isDrawer && !fromSnap.exists) {
        throw const NotFoundException("Xodim topilmadi");
      }
      if (!to.isDrawer && !toSnap.exists) {
        throw const NotFoundException("Xodim topilmadi");
      }

      if (_balanceOf(from, fromSnap) < amount) {
        throw const ValidationException("Mablag' yetarli emas");
      }

      _applyDelta(transaction, from, fromRef, fromSnap, -amount);
      _applyDelta(transaction, to, toRef, toSnap, amount);

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

  void _applyDelta(
    Transaction transaction,
    TransferParty party,
    DocumentReference<Map<String, dynamic>> ref,
    DocumentSnapshot<Map<String, dynamic>> snap,
    double delta,
  ) {
    final field = _balanceFieldOf(party);
    if (snap.exists) {
      transaction.update(ref, {field: FieldValue.increment(delta)});
    } else {
      // Faqat kassa hujjati yo'q bo'lishi mumkin (yuqorida tekshirilgan) va
      // u faqat qabul qiluvchi bo'lgandagina shu yerga tushadi.
      transaction.set(ref, {field: delta}, SetOptions(merge: true));
    }
  }
}
