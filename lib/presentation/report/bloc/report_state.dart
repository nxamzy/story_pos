import 'package:equatable/equatable.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/data/models/expense_model.dart';
import 'package:ocam_pos/data/models/sale_model.dart';

/// Hisobot davri.
enum ReportPeriod {
  day("Kun"),
  week("Hafta"),
  month("Oy");

  const ReportPeriod(this.label);

  final String label;
}

/// Davr ichida eng ko'p sotilgan mahsulot.
class TopProduct extends Equatable {
  final String name;
  final int quantity;
  final double revenue;

  const TopProduct({
    required this.name,
    required this.quantity,
    required this.revenue,
  });

  @override
  List<Object?> get props => [name, quantity, revenue];
}

class ReportState extends Equatable {
  final BlocStatus status;
  final DateTime selectedDate;
  final ReportPeriod period;

  /// Tanlangan davrdagi savdolar.
  final List<SaleModel> sales;
  final List<ExpenseModel> expenses;
  final double yearlyTotal;
  final String? error;

  ReportState({
    this.status = BlocStatus.initial,
    DateTime? selectedDate,
    this.period = ReportPeriod.day,
    this.sales = const [],
    this.expenses = const [],
    this.yearlyTotal = 0,
    this.error,
  }) : selectedDate = selectedDate ?? DateTime.now();

  /// Qaytarilgan savdolar hisobotga kirmaydi — ular bo'yicha pul ham,
  /// mahsulot ham qaytarib berilgan.
  List<SaleModel> get countedSales =>
      sales.where((sale) => !sale.refunded).toList();

  int get refundedCount => sales.length - countedSales.length;

  double get salesTotal => countedSales.fold(0, (sum, s) => sum + s.total);

  double get netIncome => countedSales.fold(0, (sum, s) => sum + s.profit);

  int get productsSold => countedSales.fold(0, (sum, s) => sum + s.itemCount);

  double get expenseTotal => expenses.fold(0, (sum, e) => sum + e.amount);

  /// Xarajatlar chiqarib tashlangandan keyingi foyda — savdodagi sof
  /// foydaning o'zi do'konning haqiqiy daromadi emas.
  double get profitAfterExpenses => netIncome - expenseTotal;

  /// Davr ichida eng ko'p sotilgan 5 ta mahsulot.
  List<TopProduct> get topProducts {
    final totals = <String, TopProduct>{};

    for (final sale in countedSales) {
      for (final item in sale.items) {
        final key = item.product.id.isEmpty ? item.product.name : item.product.id;
        final current = totals[key];
        totals[key] = TopProduct(
          name: item.product.name,
          quantity: (current?.quantity ?? 0) + item.quantity,
          revenue: (current?.revenue ?? 0) + item.subTotal,
        );
      }
    }

    final result = totals.values.toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));
    return result.take(5).toList();
  }

  ReportState copyWith({
    BlocStatus? status,
    DateTime? selectedDate,
    ReportPeriod? period,
    List<SaleModel>? sales,
    List<ExpenseModel>? expenses,
    double? yearlyTotal,
    String? error,
    bool clearError = false,
  }) {
    return ReportState(
      status: status ?? this.status,
      selectedDate: selectedDate ?? this.selectedDate,
      period: period ?? this.period,
      sales: sales ?? this.sales,
      expenses: expenses ?? this.expenses,
      yearlyTotal: yearlyTotal ?? this.yearlyTotal,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedDate,
    period,
    sales,
    expenses,
    yearlyTotal,
    error,
  ];
}
