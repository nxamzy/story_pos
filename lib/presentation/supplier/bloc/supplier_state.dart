import 'package:equatable/equatable.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/data/models/supplier_model.dart';

class SupplierState extends Equatable {
  final BlocStatus status;
  final List<SupplierModel> suppliers;
  final String query;
  final DateTime? filterDate;
  final String? error;
  final String? actionMessage;

  const SupplierState({
    this.status = BlocStatus.initial,
    this.suppliers = const [],
    this.query = '',
    this.filterDate,
    this.error,
    this.actionMessage,
  });

  List<SupplierModel> get visibleSuppliers {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return suppliers;
    return suppliers
        .where(
          (s) =>
              s.name.toLowerCase().contains(q) ||
              s.phone.contains(q) ||
              s.email.toLowerCase().contains(q),
        )
        .toList();
  }

  SupplierState copyWith({
    BlocStatus? status,
    List<SupplierModel>? suppliers,
    String? query,
    DateTime? filterDate,
    String? error,
    String? actionMessage,
    bool clearError = false,
    bool clearDate = false,
  }) {
    return SupplierState(
      status: status ?? this.status,
      suppliers: suppliers ?? this.suppliers,
      query: query ?? this.query,
      filterDate: clearDate ? null : (filterDate ?? this.filterDate),
      error: clearError ? null : (error ?? this.error),
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    suppliers,
    query,
    filterDate,
    error,
    actionMessage,
  ];
}
