import 'package:equatable/equatable.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/utils/app_config.dart';
import 'package:ocam_pos/data/models/cart_item_model.dart';
import 'package:ocam_pos/data/models/customer_model.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'package:ocam_pos/data/models/sale_model.dart';

class SaleState extends Equatable {
  final BlocStatus status;
  final List<ProductModel> products;
  final List<CartItem> cartItems;
  final String query;
  final String category;
  final CustomerModel? customer;
  final String paymentMethod;

  /// Savdo yuborilayotgan payt — "To'lash" tugmasi bloklanadi.
  final bool isProcessing;

  /// Oxirgi yakunlangan savdo — chek ekrani shuni ko'rsatadi.
  final SaleModel? completedSale;

  final String? error;
  final String? actionMessage;

  const SaleState({
    this.status = BlocStatus.initial,
    this.products = const [],
    this.cartItems = const [],
    this.query = '',
    this.category = 'Barchasi',
    this.customer,
    this.paymentMethod = 'cash',
    this.isProcessing = false,
    this.completedSale,
    this.error,
    this.actionMessage,
  });

  List<ProductModel> get visibleProducts {
    final q = query.trim().toLowerCase();
    return products.where((p) {
      final matchesQuery =
          q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.barcode.toLowerCase().contains(q);
      final matchesCategory = category == 'Barchasi' || p.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  List<String> get categories {
    final all = products
        .map((p) => p.category?.trim() ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['Barchasi', ...all];
  }

  bool get isCartEmpty => cartItems.isEmpty;

  int get totalQuantity =>
      cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get subTotal =>
      cartItems.fold(0, (sum, item) => sum + item.subTotal);

  double get tax => subTotal * AppConfig.taxRate;

  double get totalAmount => subTotal + tax;

  /// Savatdagi mahsulotning miqdorini qaytaradi (yo'q bo'lsa 0).
  int quantityOf(String productId) {
    for (final item in cartItems) {
      if (item.product.id == productId) return item.quantity;
    }
    return 0;
  }

  SaleState copyWith({
    BlocStatus? status,
    List<ProductModel>? products,
    List<CartItem>? cartItems,
    String? query,
    String? category,
    CustomerModel? customer,
    String? paymentMethod,
    bool? isProcessing,
    SaleModel? completedSale,
    String? error,
    String? actionMessage,
    bool clearError = false,
    bool clearCustomer = false,
    bool clearCompletedSale = false,
  }) {
    return SaleState(
      status: status ?? this.status,
      products: products ?? this.products,
      cartItems: cartItems ?? this.cartItems,
      query: query ?? this.query,
      category: category ?? this.category,
      customer: clearCustomer ? null : (customer ?? this.customer),
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isProcessing: isProcessing ?? this.isProcessing,
      completedSale: clearCompletedSale
          ? null
          : (completedSale ?? this.completedSale),
      error: clearError ? null : (error ?? this.error),
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    cartItems,
    query,
    category,
    customer,
    paymentMethod,
    isProcessing,
    completedSale,
    error,
    actionMessage,
  ];
}
