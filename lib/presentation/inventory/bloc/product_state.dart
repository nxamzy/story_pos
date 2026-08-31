import 'package:equatable/equatable.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/utils/app_config.dart';
import 'package:ocam_pos/data/models/product_model.dart';

class ProductState extends Equatable {
  final BlocStatus status;
  final List<ProductModel> products;
  final String query;
  final String category;
  final String? error;

  /// Qo'shish/o'chirish kabi amal tugagach bir marta ko'rsatiladigan xabar.
  final String? actionMessage;

  const ProductState({
    this.status = BlocStatus.initial,
    this.products = const [],
    this.query = '',
    this.category = 'Barchasi',
    this.error,
    this.actionMessage,
  });

  /// Qidiruv va kategoriya bo'yicha filtrlangan ro'yxat.
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

  List<ProductModel> get lowStockProducts => products
      .where((p) => p.stock <= AppConfig.lowStockThreshold)
      .toList();

  /// Ombordagi jami tovar tannarxi.
  double get inventoryValue =>
      products.fold(0, (sum, p) => sum + (p.buyPrice * p.stock));

  ProductState copyWith({
    BlocStatus? status,
    List<ProductModel>? products,
    String? query,
    String? category,
    String? error,
    String? actionMessage,
    bool clearError = false,
    bool clearActionMessage = true,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      query: query ?? this.query,
      category: category ?? this.category,
      error: clearError ? null : (error ?? this.error),
      actionMessage: clearActionMessage
          ? actionMessage
          : (actionMessage ?? this.actionMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    query,
    category,
    error,
    actionMessage,
  ];
}
