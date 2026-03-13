import 'package:ocam_pos/data/models/product_model.dart';

abstract class ProductEvent {}

class LoadProducts extends ProductEvent {} // Hamma mahsulotlarni o'qish

class AddProduct extends ProductEvent {
  // Yangi mahsulot qo'shish
  final ProductModel product;
  AddProduct(this.product);
}

class SearchProduct extends ProductEvent {
  // Shtrix-kod orqali qidirish
  final String barcode;
  SearchProduct(this.barcode);
}
