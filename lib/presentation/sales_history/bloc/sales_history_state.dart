import 'package:equatable/equatable.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/data/models/sale_model.dart';

class SalesHistoryState extends Equatable {
  final BlocStatus status;
  final List<SaleModel> sales;
  final DateTime? from;
  final DateTime? to;
  final String query;
  final String? error;

  const SalesHistoryState({
    this.status = BlocStatus.initial,
    this.sales = const [],
    this.from,
    this.to,
    this.query = '',
    this.error,
  });

  List<SaleModel> get visibleSales {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return sales;
    return sales
        .where(
          (sale) =>
              (sale.customerName ?? '').toLowerCase().contains(q) ||
              sale.id.toLowerCase().startsWith(q) ||
              (sale.cashierName ?? '').toLowerCase().contains(q),
        )
        .toList();
  }

  /// Qaytarilgan savdolar summaga qo'shilmaydi.
  double get total => visibleSales
      .where((sale) => !sale.refunded)
      .fold(0, (sum, sale) => sum + sale.total);

  SalesHistoryState copyWith({
    BlocStatus? status,
    List<SaleModel>? sales,
    DateTime? from,
    DateTime? to,
    String? query,
    String? error,
    bool clearError = false,
  }) {
    return SalesHistoryState(
      status: status ?? this.status,
      sales: sales ?? this.sales,
      from: from ?? this.from,
      to: to ?? this.to,
      query: query ?? this.query,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, sales, from, to, query, error];
}
