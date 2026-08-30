import 'package:equatable/equatable.dart';
import 'package:ocam_pos/data/models/product_model.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Mahsulotlarni real vaqtda kuzatishni boshlaydi.
class LoadProducts extends ProductEvent {
  const LoadProducts();
}

/// Ichki event: stream'dan yangi ro'yxat kelganda.
class ProductsUpdated extends ProductEvent {
  final List<ProductModel> products;
  const ProductsUpdated(this.products);

  @override
  List<Object?> get props => [products];
}

class ProductsFailed extends ProductEvent {
  final String message;
  const ProductsFailed(this.message);

  @override
  List<Object?> get props => [message];
}

class AddProduct extends ProductEvent {
  final ProductModel product;
  const AddProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProduct extends ProductEvent {
  final ProductModel product;
  const UpdateProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProduct extends ProductEvent {
  final String id;
  const DeleteProduct(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchProducts extends ProductEvent {
  final String query;
  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterProductsByCategory extends ProductEvent {
  final String category;
  const FilterProductsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}
