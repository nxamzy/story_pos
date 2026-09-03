import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/network/failure.dart';
import 'package:ocam_pos/data/repositories/sale_repository.dart';
import 'package:ocam_pos/presentation/refunds/bloc/refunds_event.dart';
import 'package:ocam_pos/presentation/refunds/bloc/refunds_state.dart';

/// Qaytarilgan savdolar ro'yxati. Ekran-lokal BLoC — faqat shu sahifaga
/// kerak, shu sababli `injection.dart`da `registerFactory`.
class RefundsBloc extends Bloc<RefundsEvent, RefundsState> {
  final SaleRepository _repository;

  RefundsBloc({required SaleRepository repository})
    : _repository = repository,
      super(const RefundsState()) {
    on<LoadRefunds>(_onLoad);
  }

  Future<void> _onLoad(LoadRefunds event, Emitter<RefundsState> emit) async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    try {
      final sales = await _repository.getRefundedSales(days: event.days);
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
