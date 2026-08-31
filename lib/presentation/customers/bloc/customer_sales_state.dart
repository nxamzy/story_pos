import 'package:equatable/equatable.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/data/models/sale_model.dart';

class CustomerSalesState extends Equatable {
  final BlocStatus status;
  final List<SaleModel> sales;
  final String? error;

  const CustomerSalesState({
    this.status = BlocStatus.initial,
    this.sales = const [],
    this.error,
  });

  CustomerSalesState copyWith({
    BlocStatus? status,
    List<SaleModel>? sales,
    String? error,
    bool clearError = false,
  }) {
    return CustomerSalesState(
      status: status ?? this.status,
      sales: sales ?? this.sales,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, sales, error];
}
