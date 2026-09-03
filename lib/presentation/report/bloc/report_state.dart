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

  /// Qaytarilgan savdolar hisobotga kirmaydi — ular bo'yicha pul ham,
  /// mahsulot ham qaytarib berilgan.
  List<SaleModel> get countedSales =>
      todaySales.where((sale) => !sale.refunded).toList();

  int get refundedCount => todaySales.length - countedSales.length;

  double get todayTotal => countedSales.fold(0, (sum, s) => sum + s.total);

  double get netIncome => countedSales.fold(0, (sum, s) => sum + s.profit);

  int get productsSold => countedSales.fold(0, (sum, s) => sum + s.itemCount);

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
