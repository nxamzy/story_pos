import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/network/failure.dart';
import 'package:ocam_pos/data/models/expense_model.dart';
import 'package:ocam_pos/data/repositories/expense_repository.dart';
import 'package:ocam_pos/presentation/expenses/bloc/expense_event.dart';
import 'package:ocam_pos/presentation/expenses/bloc/expense_state.dart';

/// Do'kon xarajatlari.
///
/// Kassadan to'langan xarajat kassa balansini kamaytiradi — buni
/// `ExpenseRemoteDataSource` bitta tranzaksiyada bajaradi, shu sababli bu
/// yerda faqat ro'yxat va filtr mantig'i bor.
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository _repository;
  StreamSubscription<List<ExpenseModel>>? _subscription;

  ExpenseBloc({required ExpenseRepository repository})
    : _repository = repository,
      super(const ExpenseState()) {
    on<LoadExpenses>(_onLoad);
    on<ExpensesUpdated>(
      (event, emit) => emit(
        state.copyWith(
          status: BlocStatus.success,
          expenses: event.expenses,
          clearError: true,
        ),
      ),
    );
    on<ExpensesFailed>(
      (event, emit) => emit(
        state.copyWith(status: BlocStatus.failure, error: event.message),
      ),
    );
    on<AddExpense>(_onAdd);
    on<DeleteExpense>(_onDelete);
    on<FilterExpensesByCategory>(
      (event, emit) => emit(state.copyWith(category: event.category)),
    );
  }

  void _onLoad(LoadExpenses event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    _subscription?.cancel();
    _subscription = _repository.watchExpenses().listen(
      (expenses) => add(ExpensesUpdated(expenses)),
      onError: (Object e) => add(ExpensesFailed(Failure.from(e).message)),
    );
  }

  Future<void> _onAdd(AddExpense event, Emitter<ExpenseState> emit) async {
    try {
      await _repository.addExpense(event.expense);
      emit(
        state.copyWith(actionMessage: "Xarajat qo'shildi", clearError: true),
      );
    } catch (error) {
      emit(state.copyWith(error: Failure.from(error).message));
    }
  }

  Future<void> _onDelete(
    DeleteExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await _repository.deleteExpense(event.id);
      emit(
        state.copyWith(actionMessage: "Xarajat o'chirildi", clearError: true),
      );
    } catch (error) {
      emit(state.copyWith(error: Failure.from(error).message));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
