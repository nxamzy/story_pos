import 'package:equatable/equatable.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/data/models/employee_model.dart';
import 'package:ocam_pos/data/models/transfer_log_model.dart';

class CashState extends Equatable {
  final BlocStatus status;

  /// O'tkazma yuborilayotgan payt — tugmani bloklash uchun.
  final bool isTransferring;
  final double balance;
  final List<EmployeeModel> employees;
  final List<TransferLogModel> logs;
  final EmployeeModel? from;
  final EmployeeModel? to;
  final String? error;
  final String? actionMessage;

  const CashState({
    this.status = BlocStatus.initial,
    this.isTransferring = false,
    this.balance = 0,
    this.employees = const [],
    this.logs = const [],
    this.from,
    this.to,
    this.error,
    this.actionMessage,
  });

  CashState copyWith({
    BlocStatus? status,
    bool? isTransferring,
    double? balance,
    List<EmployeeModel>? employees,
    List<TransferLogModel>? logs,
    EmployeeModel? from,
    EmployeeModel? to,
    String? error,
    String? actionMessage,
    bool clearError = false,
  }) {
    return CashState(
      status: status ?? this.status,
      isTransferring: isTransferring ?? this.isTransferring,
      balance: balance ?? this.balance,
      employees: employees ?? this.employees,
      logs: logs ?? this.logs,
      from: from ?? this.from,
      to: to ?? this.to,
      error: clearError ? null : (error ?? this.error),
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    isTransferring,
    balance,
    employees,
    logs,
    from,
    to,
    error,
    actionMessage,
  ];
}
