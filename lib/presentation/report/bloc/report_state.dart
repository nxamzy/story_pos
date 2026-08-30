import 'package:equatable/equatable.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/data/models/sale_model.dart';

class ReportState extends Equatable {
  final BlocStatus status;
  final DateTime selectedDate;
  final List<SaleModel> todaySales;
  final double yearlyTotal;
  final String? error;

  ReportState({
    this.status = BlocStatus.initial,
    DateTime? selectedDate,
    this.todaySales = const [],
    this.yearlyTotal = 0,
    this.error,
  }) : selectedDate = selectedDate ?? DateTime.now();

  double get todayTotal => todaySales.fold(0, (sum, s) => sum + s.total);

  double get netIncome => todaySales.fold(0, (sum, s) => sum + s.profit);

  int get productsSold =>
      todaySales.fold(0, (sum, s) => sum + s.itemCount);

  ReportState copyWith({
    BlocStatus? status,
    DateTime? selectedDate,
    List<SaleModel>? todaySales,
    double? yearlyTotal,
    String? error,
    bool clearError = false,
  }) {
    return ReportState(
      status: status ?? this.status,
      selectedDate: selectedDate ?? this.selectedDate,
      todaySales: todaySales ?? this.todaySales,
      yearlyTotal: yearlyTotal ?? this.yearlyTotal,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedDate,
    todaySales,
    yearlyTotal,
    error,
  ];
}
