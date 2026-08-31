import 'package:equatable/equatable.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/data/models/customer_model.dart';

class CustomerState extends Equatable {
  final BlocStatus status;
  final List<CustomerModel> customers;
  final String query;
  final String? error;
  final String? actionMessage;

  /// Endigina saqlangan mijoz — muvaffaqiyat varag'ini ko'rsatish uchun.
  /// `actionMessage` kabi bir martalik: keyingi `copyWith`da qayta
  /// uzatilmasa, `null`ga qaytadi.
  final CustomerModel? createdCustomer;

  const CustomerState({
    this.status = BlocStatus.initial,
    this.customers = const [],
    this.query = '',
    this.error,
    this.actionMessage,
    this.createdCustomer,
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
    CustomerModel? createdCustomer,
    bool clearError = false,
  }) {
    return CustomerState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      query: query ?? this.query,
      error: clearError ? null : (error ?? this.error),
      actionMessage: actionMessage,
      createdCustomer: createdCustomer,
    );
  }

  @override
  List<Object?> get props => [
    status,
    customers,
    query,
    error,
    actionMessage,
    createdCustomer,
  ];
}
