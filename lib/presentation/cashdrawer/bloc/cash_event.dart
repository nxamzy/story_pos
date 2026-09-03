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

/// O'tkazmani bajaradi. Taraflar state'dagi tanlovdan olinadi — shu sababli
/// bu yerda faqat summa va izoh keladi.
class TransferRequested extends CashEvent {
  final String amount;
  final String note;

  const TransferRequested({required this.amount, this.note = ''});

  @override
  List<Object?> get props => [amount, note];
}

/// Yuboruvchi/qabul qiluvchi tanlovi o'zgardi. `null` — tanlov bekor
/// qilingani (masalan o'tkazmadan keyin forma tozalanadi).
class TransferFormChanged extends CashEvent {
  final String? fromId;
  final String? toId;

  const TransferFormChanged({this.fromId, this.toId});

  @override
  List<Object?> get props => [fromId, toId];
}
