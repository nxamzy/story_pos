import 'package:equatable/equatable.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/data/models/employee_model.dart';

class EmployeeState extends Equatable {
  final BlocStatus status;
  final List<EmployeeModel> employees;
  final EmployeeModel? selected;

  /// Hozir kassada ishlayotgan xodim. Savdo shu xodim nomiga yoziladi.
  /// `null` — do'kon egasi o'zi ishlayapti.
  final EmployeeModel? activeCashier;
  final String? error;
  final String? actionMessage;

  const EmployeeState({
    this.status = BlocStatus.initial,
    this.employees = const [],
    this.selected,
    this.activeCashier,
    this.error,
    this.actionMessage,
  });

  /// Tanlangan xodim (yoki ro'yxatdagi birinchisi).
  EmployeeModel? get currentEmployee =>
      selected ?? (employees.isNotEmpty ? employees.first : null);

  double get totalSalary => employees.fold(0, (sum, e) => sum + e.salary);

  double get totalBalance => employees.fold(0, (sum, e) => sum + e.balance);

  EmployeeState copyWith({
    BlocStatus? status,
    List<EmployeeModel>? employees,
    EmployeeModel? selected,
    EmployeeModel? activeCashier,
    String? error,
    String? actionMessage,
    bool clearError = false,
    bool clearActiveCashier = false,
  }) {
    return EmployeeState(
      status: status ?? this.status,
      employees: employees ?? this.employees,
      selected: selected ?? this.selected,
      activeCashier: clearActiveCashier
          ? null
          : (activeCashier ?? this.activeCashier),
      error: clearError ? null : (error ?? this.error),
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    employees,
    selected,
    activeCashier,
    error,
    actionMessage,
  ];
}
