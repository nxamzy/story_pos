import 'package:ocam_pos/data/models/product_model.dart';

abstract class ProductEvent {}

class LoadProducts extends ProductEvent {}

class AddProduct extends ProductEvent {
  final ProductModel product;
  AddProduct(this.product);
}

class SearchProduct extends ProductEvent {
  final String barcode;
  SearchProduct(this.barcode);
}
