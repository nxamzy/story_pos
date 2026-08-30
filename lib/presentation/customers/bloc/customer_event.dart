import 'package:equatable/equatable.dart';
import 'package:ocam_pos/data/models/customer_model.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomersEvent extends CustomerEvent {
  const LoadCustomersEvent();
}

class CustomersUpdatedEvent extends CustomerEvent {
  final List<CustomerModel> customers;
  const CustomersUpdatedEvent(this.customers);

  @override
  List<Object?> get props => [customers];
}

class CustomersFailedEvent extends CustomerEvent {
  final String message;
  const CustomersFailedEvent(this.message);

  @override
  List<Object?> get props => [message];
}

/// Yangi mijoz qo'shish yoki mavjudini yangilash.
class SaveCustomerEvent extends CustomerEvent {
  final CustomerModel customer;
  const SaveCustomerEvent(this.customer);

  @override
  List<Object?> get props => [customer];
}

class DeleteCustomerEvent extends CustomerEvent {
  final String customerId;
  const DeleteCustomerEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class SearchCustomerEvent extends CustomerEvent {
  final String query;
  const SearchCustomerEvent(this.query);

  @override
  List<Object?> get props => [query];
}
