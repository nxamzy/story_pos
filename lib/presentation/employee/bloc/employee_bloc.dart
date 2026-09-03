import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/network/failure.dart';
import 'package:ocam_pos/data/models/employee_model.dart';
import 'package:ocam_pos/data/repositories/employee_repository.dart';
import 'package:ocam_pos/presentation/employee/bloc/employee_event.dart';
import 'package:ocam_pos/presentation/employee/bloc/employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final EmployeeRepository _repository;
  StreamSubscription<List<EmployeeModel>>? _subscription;

  EmployeeBloc({required EmployeeRepository repository})
    : _repository = repository,
      super(const EmployeeState()) {
    on<LoadEmployees>(_onLoad);
    on<EmployeesUpdated>(
      (event, emit) => emit(
        state.copyWith(
          status: BlocStatus.success,
          employees: event.employees,
          clearError: true,
        ),
      ),
    );
    on<EmployeesFailed>(
      (event, emit) => emit(
        state.copyWith(status: BlocStatus.failure, error: event.message),
      ),
    );
    on<AddEmployee>(_onAdd);
    on<UpdateEmployee>(_onUpdate);
    on<DeleteEmployee>(_onDelete);
    on<SelectEmployee>(
      (event, emit) => emit(state.copyWith(selected: event.employee)),
    );
  }

  void _onLoad(LoadEmployees event, Emitter<EmployeeState> emit) {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    _subscription?.cancel();
    _subscription = _repository.watchEmployees().listen(
      (employees) => add(EmployeesUpdated(employees)),
      onError: (Object e) => add(EmployeesFailed(Failure.from(e).message)),
    );
  }

  Future<void> _onAdd(AddEmployee event, Emitter<EmployeeState> emit) async {
    if (event.employee.name.trim().isEmpty) {
      emit(state.copyWith(error: "Xodim ismini kiriting"));
      return;
    }
    try {
      await _repository.addEmployee(event.employee);
      emit(state.copyWith(actionMessage: "Xodim qo'shildi", clearError: true));
    } catch (error) {
      emit(state.copyWith(error: Failure.from(error).message));
    }
  }

  Future<void> _onUpdate(
    UpdateEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    if (event.employee.name.trim().isEmpty) {
      emit(state.copyWith(error: "Xodim ismini kiriting"));
      return;
    }
    try {
      await _repository.updateEmployee(event.employee);
      emit(
        state.copyWith(actionMessage: "Ma'lumot yangilandi", clearError: true),
      );
    } catch (error) {
      emit(state.copyWith(error: Failure.from(error).message));
    }
  }

  Future<void> _onDelete(
    DeleteEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    try {
      await _repository.deleteEmployee(event.id);
      emit(state.copyWith(actionMessage: "Xodim o'chirildi", clearError: true));
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
