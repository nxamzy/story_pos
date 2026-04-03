import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/data/models/employee_model.dart';
import 'package:ocam_pos/data/repositories/cash_repository.dart';

abstract class CashState {}

class CashInitial extends CashState {}

class CashLoading extends CashState {}

class CashSuccess extends CashState {}

class CashError extends CashState {
  final String message;
  CashError(this.message);
}

class CashBloc extends Cubit<CashState> {
  final CashRepository repository;

  CashBloc(this.repository) : super(CashInitial());

  Future<void> executeTransfer({
    required EmployeeModel? from,
    required EmployeeModel? to,
    required String amountStr,
    required String note,
  }) async {
    final amount = double.tryParse(amountStr) ?? 0;

    if (from == null || to == null) {
      emit(CashError("Xodimlarni tanlang!"));
      return;
    }
    if (from.id == to.id) {
      emit(CashError("O'ziga o'tkazma qilib bo'lmaydi"));
      return;
    }
    if (amount <= 0) {
      emit(CashError("To'g'ri summa kiriting"));
      return;
    }
    if (from.balance < amount) {
      emit(CashError("Yuboruvchida mablag' yetarli emas"));
      return;
    }

    emit(CashLoading());
    try {
      await repository.transferBalance(
        from: from,
        to: to,
        amount: amount,
        note: note,
      );
      emit(CashSuccess());
    } catch (e) {
      emit(CashError("O'tkazmada xatolik: ${e.toString()}"));
    }
  }

  Future<void> addEmployee(EmployeeModel employee) async {
    if (employee.name.isEmpty) {
      emit(CashError("Ism bo'sh bo'lishi mumkin emas"));
      return;
    }

    emit(CashLoading());
    try {
      await repository.addEmployee(employee);
      emit(CashSuccess());
    } catch (e) {
      emit(CashError("Xodim qo'shishda xatolik: ${e.toString()}"));
    }
  }
}
