import 'package:equatable/equatable.dart';

abstract class CustomerSalesEvent extends Equatable {
  const CustomerSalesEvent();

  @override
  List<Object?> get props => [];
}

/// Bitta mijozning xarid tarixini yuklaydi.
class LoadCustomerSales extends CustomerSalesEvent {
  final String customerId;
  const LoadCustomerSales(this.customerId);

  @override
  List<Object?> get props => [customerId];
}
