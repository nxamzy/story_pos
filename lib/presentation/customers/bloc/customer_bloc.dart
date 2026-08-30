import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/network/failure.dart';
import 'package:ocam_pos/data/models/customer_model.dart';
import 'package:ocam_pos/data/repositories/customer_repository.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_event.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository _repository;
  StreamSubscription<List<CustomerModel>>? _subscription;

  CustomerBloc({required CustomerRepository repository})
    : _repository = repository,
      super(const CustomerState()) {
    on<LoadCustomersEvent>(_onLoad);
    on<CustomersUpdatedEvent>(
      (event, emit) => emit(
        state.copyWith(
          status: BlocStatus.success,
          customers: event.customers,
          clearError: true,
        ),
      ),
    );
    on<CustomersFailedEvent>(
      (event, emit) => emit(
        state.copyWith(status: BlocStatus.failure, error: event.message),
      ),
    );
    on<SaveCustomerEvent>(_onSave);
    on<DeleteCustomerEvent>(_onDelete);
    on<SearchCustomerEvent>(
      (event, emit) => emit(state.copyWith(query: event.query)),
    );
  }

  void _onLoad(LoadCustomersEvent event, Emitter<CustomerState> emit) {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    _subscription?.cancel();
    _subscription = _repository.watchCustomers().listen(
      (customers) => add(CustomersUpdatedEvent(customers)),
      onError: (Object e) => add(CustomersFailedEvent(Failure.from(e).message)),
    );
  }

  Future<void> _onSave(
    SaveCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    if (event.customer.name.trim().isEmpty) {
      emit(state.copyWith(error: "Mijoz ismini kiriting"));
      return;
    }
    try {
      await _repository.addCustomer(event.customer);
      emit(state.copyWith(actionMessage: "Mijoz saqlandi", clearError: true));
    } catch (error) {
      emit(state.copyWith(error: Failure.from(error).message));
    }
  }

  Future<void> _onDelete(
    DeleteCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      await _repository.deleteCustomer(event.customerId);
      emit(state.copyWith(actionMessage: "Mijoz o'chirildi", clearError: true));
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
