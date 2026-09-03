import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocam_pos/core/network/exceptions.dart';
import 'package:ocam_pos/core/network/firestore_paths.dart';
import 'package:ocam_pos/data/models/expense_model.dart';

abstract class ExpenseRemoteDataSource {
  Stream<List<ExpenseModel>> watchExpenses({DateTime? from, DateTime? to});
  Future<List<ExpenseModel>> getExpenses({DateTime? from, DateTime? to});

  /// Xarajatni yozadi. Kassadan to'langan bo'lsa kassa balansi ham shu
  /// tranzaksiyada kamayadi.
  Future<String> addExpense(ExpenseModel expense);

  /// Xarajatni o'chiradi. Kassadan to'langan bo'lgan bo'lsa pul kassaga
  /// qaytariladi — aks holda balans noto'g'ri qolib ketardi.
  Future<void> deleteExpense(String id);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final FirestorePaths _paths;

  ExpenseRemoteDataSourceImpl({required FirestorePaths paths}) : _paths = paths;

  Query<Map<String, dynamic>> _query({DateTime? from, DateTime? to}) {
    Query<Map<String, dynamic>> query = _paths.expenses;
    if (from != null) {
      query = query.where(
        'createdAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(from),
      );
    }
    if (to != null) {
      query = query.where('createdAt', isLessThan: Timestamp.fromDate(to));
    }
    return query.orderBy('createdAt', descending: true);
  }

  @override
  Stream<List<ExpenseModel>> watchExpenses({DateTime? from, DateTime? to}) =>
      _query(from: from, to: to).snapshots().map(
        (snap) => snap.docs
            .map((doc) => ExpenseModel.fromMap(doc.data(), doc.id))
            .toList(),
      );

  @override
  Future<List<ExpenseModel>> getExpenses({DateTime? from, DateTime? to}) async {
    final snap = await _query(from: from, to: to).get();
    return snap.docs
        .map((doc) => ExpenseModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<String> addExpense(ExpenseModel expense) async {
    if (expense.amount <= 0) {
      throw const ValidationException("Summa 0 dan katta bo'lishi kerak");
    }
    if (expense.title.trim().isEmpty) {
      throw const ValidationException("Xarajat nomini kiriting");
    }

    final doc = _paths.expenses.doc();

    if (!expense.fromDrawer) {
      await doc.set({
        ...expense.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    }

    final drawerRef = _paths.drawer;

    await _paths.db.runTransaction((transaction) async {
      final drawerSnap = await transaction.get(drawerRef);
      final balance =
          (drawerSnap.data()?['current_balance'] as num?)?.toDouble() ?? 0;

      if (balance < expense.amount) {
        throw const ValidationException("Kassada yetarli mablag' yo'q");
      }

      transaction.update(drawerRef, {
        'current_balance': FieldValue.increment(-expense.amount),
      });
      transaction.set(doc, {
        ...expense.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    return doc.id;
  }

  @override
  Future<void> deleteExpense(String id) async {
    final expenseRef = _paths.expenses.doc(id);
    final drawerRef = _paths.drawer;

    await _paths.db.runTransaction((transaction) async {
      final snap = await transaction.get(expenseRef);
      if (!snap.exists) {
        throw const NotFoundException("Xarajat topilmadi");
      }

      final expense = ExpenseModel.fromMap(snap.data()!, snap.id);
      if (expense.fromDrawer) {
        transaction.update(drawerRef, {
          'current_balance': FieldValue.increment(expense.amount),
        });
      }
      transaction.delete(expenseRef);
    });
  }
}
