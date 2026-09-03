import 'package:equatable/equatable.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/data/models/sale_model.dart';

class RefundsState extends Equatable {
  final BlocStatus status;
  final List<SaleModel> sales;
  final String? error;

  const RefundsState({
    this.status = BlocStatus.initial,
    this.sales = const [],
    this.error,
  });

  /// Qaytarilgan savdolarning umumiy summasi.
  double get totalAmount => sales.fold(0, (sum, sale) => sum + sale.total);

  RefundsState copyWith({
    BlocStatus? status,
    List<SaleModel>? sales,
    String? error,
    bool clearError = false,
  }) {
    return RefundsState(
      status: status ?? this.status,
      sales: sales ?? this.sales,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, sales, error];
}
