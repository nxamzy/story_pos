import 'package:ocam_pos/data/models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subTotal => product.sellPrice * quantity;

  // 🔥 Bazaga (sales collection) yozish uchun qulay format
  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'name': product.name,
      'quantity': quantity,
      'price': product.sellPrice,
      'subTotal': subTotal,
    };
  }

  CartItem copyWith({int? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }
}
