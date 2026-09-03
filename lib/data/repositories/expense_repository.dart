import 'package:ocam_pos/data/datasources/expense_remote_datasource.dart';
import 'package:ocam_pos/data/models/expense_model.dart';
import 'package:ocam_pos/data/repositories/repository_guard.dart';

class ExpenseRepository with RepositoryGuard {
  final ExpenseRemoteDataSource _remote;

  ExpenseRepository({required ExpenseRemoteDataSource remote})
    : _remote = remote;

  Stream<List<ExpenseModel>> watchExpenses({DateTime? from, DateTime? to}) =>
      guardStream(() => _remote.watchExpenses(from: from, to: to));

  Future<List<ExpenseModel>> getExpenses({DateTime? from, DateTime? to}) =>
      guard(() => _remote.getExpenses(from: from, to: to));

  Future<String> addExpense(ExpenseModel expense) =>
      guard(() => _remote.addExpense(expense));

  Future<void> deleteExpense(String id) =>
      guard(() => _remote.deleteExpense(id));
}
