import 'package:equatable/equatable.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/data/models/expense_model.dart';

class ExpenseState extends Equatable {
  final BlocStatus status;
  final List<ExpenseModel> expenses;
  final String category;
  final String? error;
  final String? actionMessage;

  const ExpenseState({
    this.status = BlocStatus.initial,
    this.expenses = const [],
    this.category = 'Barchasi',
    this.error,
    this.actionMessage,
  });

  List<ExpenseModel> get visibleExpenses => category == 'Barchasi'
      ? expenses
      : expenses.where((e) => e.category == category).toList();

  List<String> get categories => ['Barchasi', ...ExpenseModel.categories];

  /// Ko'rinib turgan xarajatlar summasi.
  double get visibleTotal =>
      visibleExpenses.fold(0, (sum, expense) => sum + expense.amount);

  /// Shu oydagi xarajatlar summasi — sahifa sarlavhasida ko'rsatiladi.
  double get monthTotal {
    final now = DateTime.now();
    return expenses
        .where(
          (e) => e.createdAt.year == now.year && e.createdAt.month == now.month,
        )
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  ExpenseState copyWith({
    BlocStatus? status,
    List<ExpenseModel>? expenses,
    String? category,
    String? error,
    String? actionMessage,
    bool clearError = false,
  }) {
    return ExpenseState(
      status: status ?? this.status,
      expenses: expenses ?? this.expenses,
      category: category ?? this.category,
      error: clearError ? null : (error ?? this.error),
      // Bir martalik xabar: keyingi holatga o'tib ketmaydi.
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    expenses,
    category,
    error,
    actionMessage,
  ];
}
