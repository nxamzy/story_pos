import 'package:ocam_pos/data/datasources/employee_remote_datasource.dart';
import 'package:ocam_pos/data/models/employee_model.dart';
import 'package:ocam_pos/data/models/transfer_log_model.dart';
import 'package:ocam_pos/data/models/transfer_party_model.dart';
import 'package:ocam_pos/data/repositories/repository_guard.dart';

class EmployeeRepository with RepositoryGuard {
  final EmployeeRemoteDataSource _remote;

  EmployeeRepository({required EmployeeRemoteDataSource remote})
    : _remote = remote;

  Stream<List<EmployeeModel>> watchEmployees() =>
      guardStream(_remote.watchEmployees);

  Future<String> addEmployee(EmployeeModel employee) =>
      guard(() => _remote.addEmployee(employee));

  Future<void> updateEmployee(EmployeeModel employee) =>
      guard(() => _remote.updateEmployee(employee));

  Future<void> deleteEmployee(String id) =>
      guard(() => _remote.deleteEmployee(id));

  Stream<double> watchDrawerBalance() =>
      guardStream(_remote.watchDrawerBalance);

  Stream<List<TransferLogModel>> watchTransferLogs({int limit = 50}) =>
      guardStream(() => _remote.watchTransferLogs(limit: limit));

  Future<void> transferBalance({
    required TransferParty from,
    required TransferParty to,
    required double amount,
    required String note,
  }) => guard(
    () => _remote.transferBalance(
      from: from,
      to: to,
      amount: amount,
      note: note,
    ),
  );
}
