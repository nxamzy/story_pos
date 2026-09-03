import 'package:equatable/equatable.dart';
import 'package:ocam_pos/data/models/customer_model.dart';
import 'package:ocam_pos/data/models/product_model.dart';

abstract class SaleEvent extends Equatable {
  const SaleEvent();

  @override
  List<Object?> get props => [];
}

/// Sotuv ekrani uchun mahsulotlarni kuzatishni boshlaydi.
class LoadSaleProducts extends SaleEvent {
  const LoadSaleProducts();
}

class SaleProductsUpdated extends SaleEvent {
  final List<ProductModel> products;
  const SaleProductsUpdated(this.products);

  @override
  List<Object?> get props => [products];
}

class SaleProductsFailed extends SaleEvent {
  final String message;
  const SaleProductsFailed(this.message);

  @override
  List<Object?> get props => [message];
}

class SearchSaleProducts extends SaleEvent {
  final String query;
  const SearchSaleProducts(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterSaleByCategory extends SaleEvent {
  final String category;
  const FilterSaleByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Shtrix-kod skanerlandi — mahsulot topilsa savatga qo'shiladi.
class ScanBarcodeEvent extends SaleEvent {
  final String barcode;
  const ScanBarcodeEvent(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

class AddProductToCartEvent extends SaleEvent {
  final ProductModel product;
  const AddProductToCartEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateQuantityEvent extends SaleEvent {
  final String productId;
  final int quantity;
  const UpdateQuantityEvent(this.productId, this.quantity);

  @override
  List<Object?> get props => [productId, quantity];
}

class RemoveFromCartEvent extends SaleEvent {
  final String productId;
  const RemoveFromCartEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ClearCartEvent extends SaleEvent {
  const ClearCartEvent();
}

class SelectSaleCustomerEvent extends SaleEvent {
  final CustomerModel? customer;
  const SelectSaleCustomerEvent(this.customer);

  @override
  List<Object?> get props => [customer];
}

class SelectPaymentMethodEvent extends SaleEvent {
  final String method;
  const SelectPaymentMethodEvent(this.method);

  @override
  List<Object?> get props => [method];
}

/// Savdoni yakunlaydi: chek yoziladi, ombor kamayadi, kassa to'ldiriladi.
class CompleteSaleEvent extends SaleEvent {
  final double amountPaid;
  final String? note;
  final DateTime? date;

  const CompleteSaleEvent({required this.amountPaid, this.note, this.date});

  @override
  List<Object?> get props => [amountPaid, note, date];
}

/// Yakunlangan savdoni qaytaradi (bekor qiladi).
class RefundSaleEvent extends SaleEvent {
  final String saleId;
  const RefundSaleEvent(this.saleId);

  @override
  List<Object?> get props => [saleId];
}

/// Ko'rsatilgan xabar/xato o'qildi.
class SaleMessageCleared extends SaleEvent {
  const SaleMessageCleared();
}
