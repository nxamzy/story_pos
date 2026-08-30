import 'package:equatable/equatable.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/data/models/customer_model.dart';

class CustomerState extends Equatable {
  final BlocStatus status;
  final List<CustomerModel> customers;
  final String query;
  final String? error;
  final String? actionMessage;

  const CustomerState({
    this.status = BlocStatus.initial,
    this.customers = const [],
    this.query = '',
    this.error,
    this.actionMessage,
  });

  /// Qidiruv natijasi — ism yoki telefon bo'yicha.
  List<CustomerModel> get visibleCustomers {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return customers;
    return customers
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.phone.replaceAll(' ', '').contains(q.replaceAll(' ', '')),
        )
        .toList();
  }

  CustomerState copyWith({
    BlocStatus? status,
    List<CustomerModel>? customers,
    String? query,
    String? error,
    String? actionMessage,
    bool clearError = false,
  }) {
    return CustomerState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      query: query ?? this.query,
      error: clearError ? null : (error ?? this.error),
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [status, customers, query, error, actionMessage];
}
