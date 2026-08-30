import 'package:equatable/equatable.dart';
import 'package:ocam_pos/data/models/model_utils.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final String barcode;
  final double buyPrice;
  final double sellPrice;
  final int stock;
  final String? category;
  final String? imageUrl;
  final String? description;
  final DateTime? createdAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.barcode,
    required this.buyPrice,
    required this.sellPrice,
    required this.stock,
    this.category,
    this.imageUrl,
    this.description,
    this.createdAt,
  });

  /// Sotuvdan tushadigan foyda (bir dona uchun).
  double get profitPerUnit => sellPrice - buyPrice;

  bool get isOutOfStock => stock <= 0;

  factory ProductModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProductModel(
      id: documentId,
      name: ModelUtils.toStr(map['name']),
      barcode: ModelUtils.toStr(map['barcode']),
      buyPrice: ModelUtils.toDouble(map['buyPrice']),
      sellPrice: ModelUtils.toDouble(map['sellPrice']),
      stock: ModelUtils.toInt(map['stock']),
      category: map['category'] as String?,
      imageUrl: map['imageUrl'] as String?,
      description: map['description'] as String?,
      createdAt: ModelUtils.dateOrNull(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'barcode': barcode,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'stock': stock,
      'category': category,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? barcode,
    double? buyPrice,
    double? sellPrice,
    int? stock,
    String? category,
    String? imageUrl,
    String? description,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    barcode,
    buyPrice,
    sellPrice,
    stock,
    category,
    imageUrl,
    description,
  ];
}
