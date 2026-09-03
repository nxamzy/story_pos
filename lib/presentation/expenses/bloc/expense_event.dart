import 'package:equatable/equatable.dart';
import 'package:ocam_pos/data/models/expense_model.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

/// Xarajatlarni real vaqtda kuzatishni boshlaydi.
class LoadExpenses extends ExpenseEvent {
  const LoadExpenses();
}

/// Ichki event: stream'dan yangi ro'yxat kelganda.
class ExpensesUpdated extends ExpenseEvent {
  final List<ExpenseModel> expenses;
  const ExpensesUpdated(this.expenses);

  @override
  List<Object?> get props => [expenses];
}

class ExpensesFailed extends ExpenseEvent {
  final String message;
  const ExpensesFailed(this.message);

  @override
  List<Object?> get props => [message];
}

class AddExpense extends ExpenseEvent {
  final ExpenseModel expense;
  const AddExpense(this.expense);

  @override
  List<Object?> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  final String id;
  const DeleteExpense(this.id);

  @override
  List<Object?> get props => [id];
}

/// Ro'yxatni tur bo'yicha filtrlash ('Barchasi' — hammasi).
class FilterExpensesByCategory extends ExpenseEvent {
  final String category;
  const FilterExpensesByCategory(this.category);

  @override
  List<Object?> get props => [category];
}
