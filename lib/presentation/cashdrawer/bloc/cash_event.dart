import 'package:equatable/equatable.dart';
import 'package:ocam_pos/data/models/employee_model.dart';
import 'package:ocam_pos/data/models/transfer_log_model.dart';

abstract class CashEvent extends Equatable {
  const CashEvent();

  @override
  List<Object?> get props => [];
}

class LoadCashDrawer extends CashEvent {
  const LoadCashDrawer();
}

class CashDataUpdated extends CashEvent {
  final double? balance;
  final List<EmployeeModel>? employees;
  final List<TransferLogModel>? logs;

  const CashDataUpdated({this.balance, this.employees, this.logs});

  @override
  List<Object?> get props => [balance, employees, logs];
}

class CashFailed extends CashEvent {
  final String message;
  const CashFailed(this.message);

  @override
  List<Object?> get props => [message];
}

class TransferRequested extends CashEvent {
  final EmployeeModel? from;
  final EmployeeModel? to;
  final String amount;
  final String note;

  const TransferRequested({
    required this.from,
    required this.to,
    required this.amount,
    this.note = '',
  });

  @override
  List<Object?> get props => [from, to, amount, note];
}

class TransferFormChanged extends CashEvent {
  final EmployeeModel? from;
  final EmployeeModel? to;

  const TransferFormChanged({this.from, this.to});

  @override
  List<Object?> get props => [from, to];
}
