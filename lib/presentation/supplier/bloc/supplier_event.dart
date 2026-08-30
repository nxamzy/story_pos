import 'package:equatable/equatable.dart';
import 'package:ocam_pos/data/models/supplier_model.dart';

abstract class SupplierEvent extends Equatable {
  const SupplierEvent();

  @override
  List<Object?> get props => [];
}

class LoadSuppliers extends SupplierEvent {
  /// Sana bo'yicha filtr (null bo'lsa — hammasi).
  final DateTime? date;
  const LoadSuppliers({this.date});

  @override
  List<Object?> get props => [date];
}

class SuppliersUpdated extends SupplierEvent {
  final List<SupplierModel> suppliers;
  const SuppliersUpdated(this.suppliers);

  @override
  List<Object?> get props => [suppliers];
}

class SuppliersFailed extends SupplierEvent {
  final String message;
  const SuppliersFailed(this.message);

  @override
  List<Object?> get props => [message];
}

class AddSupplier extends SupplierEvent {
  final SupplierModel supplier;
  const AddSupplier(this.supplier);

  @override
  List<Object?> get props => [supplier];
}

class UpdateSupplier extends SupplierEvent {
  final SupplierModel supplier;
  const UpdateSupplier(this.supplier);

  @override
  List<Object?> get props => [supplier];
}

class DeleteSupplier extends SupplierEvent {
  final String id;
  const DeleteSupplier(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchSuppliers extends SupplierEvent {
  final String query;
  const SearchSuppliers(this.query);

  @override
  List<Object?> get props => [query];
}
