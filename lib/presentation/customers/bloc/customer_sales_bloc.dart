import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/network/failure.dart';
import 'package:ocam_pos/data/repositories/sale_repository.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_sales_event.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_sales_state.dart';

/// Ekran-lokal BLoC — faqat `CustomerDetailsPage`ga tegishli, shu sababli
/// `injection.dart`da `registerFactory` bilan ro'yxatdan o'tgan (boshqa
/// BLoC'lardek ildizda bitta marta emas).
class CustomerSalesBloc extends Bloc<CustomerSalesEvent, CustomerSalesState> {
  final SaleRepository _repository;

  CustomerSalesBloc({required SaleRepository repository})
    : _repository = repository,
      super(const CustomerSalesState()) {
    on<LoadCustomerSales>(_onLoad);
  }

  Future<void> _onLoad(
    LoadCustomerSales event,
    Emitter<CustomerSalesState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    try {
      final sales = await _repository.getSalesByCustomer(event.customerId);
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
