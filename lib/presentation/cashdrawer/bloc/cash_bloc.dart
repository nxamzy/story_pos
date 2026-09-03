import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/network/failure.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/data/repositories/employee_repository.dart';
import 'package:ocam_pos/presentation/cashdrawer/bloc/cash_event.dart';
import 'package:ocam_pos/presentation/cashdrawer/bloc/cash_state.dart';

/// Kassa: balans, xodimlar va ular o'rtasidagi pul o'tkazmalari.
class CashBloc extends Bloc<CashEvent, CashState> {
  final EmployeeRepository _repository;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  CashBloc({required EmployeeRepository repository})
    : _repository = repository,
      super(const CashState()) {
    on<LoadCashDrawer>(_onLoad);
    on<CashDataUpdated>(_onDataUpdated);
    on<CashFailed>(
      (event, emit) => emit(
        state.copyWith(
          status: BlocStatus.failure,
          error: event.message,
          isTransferring: false,
        ),
      ),
    );
    on<TransferFormChanged>(
      (event, emit) => emit(
        state.copyWith(
          fromId: event.fromId,
          toId: event.toId,
          clearFrom: event.fromId == null,
          clearTo: event.toId == null,
          clearError: true,
        ),
      ),
    );
    on<TransferRequested>(_onTransfer);
  }

  void _onLoad(LoadCashDrawer event, Emitter<CashState> emit) {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));

    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions
      ..clear()
      ..add(
        _repository.watchDrawerBalance().listen(
          (balance) => add(CashDataUpdated(balance: balance)),
          onError: (Object e) => add(CashFailed(Failure.from(e).message)),
        ),
      )
      ..add(
        _repository.watchEmployees().listen(
          (employees) => add(CashDataUpdated(employees: employees)),
          onError: (Object e) => add(CashFailed(Failure.from(e).message)),
        ),
      )
      ..add(
        _repository.watchTransferLogs().listen(
          (logs) => add(CashDataUpdated(logs: logs)),
          onError: (Object e) => add(CashFailed(Failure.from(e).message)),
        ),
      );
  }

  void _onDataUpdated(CashDataUpdated event, Emitter<CashState> emit) {
    emit(
      state.copyWith(
        status: BlocStatus.success,
        balance: event.balance,
        employees: event.employees,
        logs: event.logs,
        clearError: true,
      ),
    );
  }

  Future<void> _onTransfer(
    TransferRequested event,
    Emitter<CashState> emit,
  ) async {
    final amount = AppFormat.parseAmount(event.amount);
    // Taraflar (va ularning joriy balansi) state'dan olinadi — forma
    // ochilgandan keyin balans o'zgargan bo'lsa ham tekshiruv to'g'ri
    // bo'ladi.
    final from = state.from;
    final to = state.to;

    if (from == null || to == null) {
      emit(state.copyWith(error: "Yuboruvchi va qabul qiluvchini tanlang"));
      return;
    }
    if (from.id == to.id) {
      emit(state.copyWith(error: "O'ziga o'tkazma qilib bo'lmaydi"));
      return;
    }
    if (amount <= 0) {
      emit(state.copyWith(error: "To'g'ri summa kiriting"));
      return;
    }
    if (from.balance < amount) {
      emit(
        state.copyWith(
          error: from.isDrawer
              ? "Kassada mablag' yetarli emas"
              : "Yuboruvchida mablag' yetarli emas",
        ),
      );
      return;
    }

    emit(state.copyWith(isTransferring: true, clearError: true));
    try {
      await _repository.transferBalance(
        from: from,
        to: to,
        amount: amount,
        note: event.note,
      );
      emit(
        state.copyWith(
          isTransferring: false,
          actionMessage:
              "${from.name} -> ${to.name}: ${AppFormat.money(amount)} o'tkazildi",
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isTransferring: false,
          error: Failure.from(error).message,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    return super.close();
  }
}
