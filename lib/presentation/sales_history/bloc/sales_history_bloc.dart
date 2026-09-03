import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/network/failure.dart';
import 'package:ocam_pos/data/repositories/sale_repository.dart';
import 'package:ocam_pos/presentation/sales_history/bloc/sales_history_event.dart';
import 'package:ocam_pos/presentation/sales_history/bloc/sales_history_state.dart';

/// Savdolar tarixi — eski chekni topish uchun.
///
/// Ekran-lokal BLoC (`registerFactory`): hisobot bir kunni ko'rsatadi, bu
/// yerda esa davr tanlanadi va qidiruv bor.
class SalesHistoryBloc extends Bloc<SalesHistoryEvent, SalesHistoryState> {
  final SaleRepository _repository;

  SalesHistoryBloc({required SaleRepository repository})
    : _repository = repository,
      super(const SalesHistoryState()) {
    on<LoadSalesHistory>(_onLoad);
    on<SearchSalesHistory>(
      (event, emit) => emit(state.copyWith(query: event.query)),
    );
  }

  Future<void> _onLoad(
    LoadSalesHistory event,
    Emitter<SalesHistoryState> emit,
  ) async {
    emit(
      state.copyWith(
        status: BlocStatus.loading,
        from: event.from,
        to: event.to,
        clearError: true,
      ),
    );

    try {
      final sales = await _repository.getSales(from: event.from, to: event.to);
      emit(state.copyWith(status: BlocStatus.success, sales: sales));
    } catch (error) {
      emit(
        state.copyWith(
          status: BlocStatus.failure,
          error: Failure.from(error).message,
        ),
      );
    }
  }
}
