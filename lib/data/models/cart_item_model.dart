import 'package:equatable/equatable.dart';
import 'package:ocam_pos/data/models/model_utils.dart';
import 'package:ocam_pos/data/models/product_model.dart';

/// Savatdagi bitta qator. O'zgarmas (immutable) — miqdorni o'zgartirish uchun
/// `copyWith` ishlatiladi, shunda BLoC state'i to'g'ri yangilanadi.
class CartItem extends Equatable {
  final ProductModel product;
  final int quantity;

  const CartItem({required this.product, this.quantity = 1});

  double get subTotal => product.sellPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'name': product.name,
      'barcode': product.barcode,
      'quantity': quantity,
      'price': product.sellPrice,
      'buyPrice': product.buyPrice,
      'subTotal': subTotal,
    };
  }

  /// Sotuv tarixidan qayta o'qish uchun (mahsulot o'chirilgan bo'lsa ham ishlaydi).
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: ProductModel(
        id: ModelUtils.toStr(map['productId']),
        name: ModelUtils.toStr(map['name']),
        barcode: ModelUtils.toStr(map['barcode']),
        buyPrice: ModelUtils.toDouble(map['buyPrice']),
        sellPrice: ModelUtils.toDouble(map['price']),
        stock: 0,
      ),
      quantity: ModelUtils.toInt(map['quantity'], 1),
    );
  }

  CartItem copyWith({ProductModel? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [product, quantity];
}
