import 'package:equatable/equatable.dart';
import 'package:ocam_pos/data/models/employee_model.dart';

abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();

  @override
  List<Object?> get props => [];
}

class LoadEmployees extends EmployeeEvent {
  const LoadEmployees();
}

class EmployeesUpdated extends EmployeeEvent {
  final List<EmployeeModel> employees;
  const EmployeesUpdated(this.employees);

  @override
  List<Object?> get props => [employees];
}

class EmployeesFailed extends EmployeeEvent {
  final String message;
  const EmployeesFailed(this.message);

  @override
  List<Object?> get props => [message];
}

class AddEmployee extends EmployeeEvent {
  final EmployeeModel employee;
  const AddEmployee(this.employee);

  @override
  List<Object?> get props => [employee];
}

class UpdateEmployee extends EmployeeEvent {
  final EmployeeModel employee;
  const UpdateEmployee(this.employee);

  @override
  List<Object?> get props => [employee];
}

class DeleteEmployee extends EmployeeEvent {
  final String id;
  const DeleteEmployee(this.id);

  @override
  List<Object?> get props => [id];
}

class SelectEmployee extends EmployeeEvent {
  final EmployeeModel? employee;
  const SelectEmployee(this.employee);

  @override
  List<Object?> get props => [employee];
}
