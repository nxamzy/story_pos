import 'package:equatable/equatable.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/data/models/employee_model.dart';
import 'package:ocam_pos/data/models/transfer_log_model.dart';
import 'package:ocam_pos/data/models/transfer_party_model.dart';

class CashState extends Equatable {
  final BlocStatus status;

  /// O'tkazma yuborilayotgan payt — tugmani bloklash uchun.
  final bool isTransferring;
  final double balance;
  final List<EmployeeModel> employees;
  final List<TransferLogModel> logs;

  /// Tanlangan taraflarning id'si. Obyektning o'zi emas, aynan id
  /// saqlanadi — shunda balans o'zgarganda ([balance], [employees] yangi
  /// qiymat olganda) tanlov eskirgan summani ko'rsatib qolmaydi.
  final String? fromId;
  final String? toId;

  final String? error;
  final String? actionMessage;

  const CashState({
    this.status = BlocStatus.initial,
    this.isTransferring = false,
    this.balance = 0,
    this.employees = const [],
    this.logs = const [],
    this.fromId,
    this.toId,
    this.error,
    this.actionMessage,
  });

  /// O'tkazmada qatnasha oladigan taraflar: kassa va barcha xodimlar.
  List<TransferParty> get parties => [
    TransferParty.drawer(balance),
    ...employees.map(TransferParty.fromEmployee),
  ];

  TransferParty? get from => partyById(fromId);
  TransferParty? get to => partyById(toId);

  TransferParty? partyById(String? id) {
    if (id == null) return null;
    for (final party in parties) {
      if (party.id == id) return party;
    }
    return null;
  }

  CashState copyWith({
    BlocStatus? status,
    bool? isTransferring,
    double? balance,
    List<EmployeeModel>? employees,
    List<TransferLogModel>? logs,
    String? fromId,
    String? toId,
    String? error,
    String? actionMessage,
    bool clearError = false,
    bool clearFrom = false,
    bool clearTo = false,
  }) {
    return CashState(
      status: status ?? this.status,
      isTransferring: isTransferring ?? this.isTransferring,
      balance: balance ?? this.balance,
      employees: employees ?? this.employees,
      logs: logs ?? this.logs,
      fromId: clearFrom ? null : (fromId ?? this.fromId),
      toId: clearTo ? null : (toId ?? this.toId),
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
    fromId,
    toId,
    error,
    actionMessage,
  ];
}
