import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String userId;
  final String barcode;
  final double buyPrice;
  final double sellPrice;
  final int stock;
  final String? category;
  final String? imageUrl;
  final String? description;

  ProductModel({
    required this.id,
    required this.name,
    required this.userId,
    required this.barcode,
    required this.buyPrice,
    required this.sellPrice,
    required this.stock,
    this.category,
    this.imageUrl,
    this.description,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProductModel(
      id: documentId,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      barcode: map['barcode'] ?? '',
      buyPrice: (map['buyPrice'] ?? 0.0).toDouble(),
      sellPrice: (map['sellPrice'] ?? 0.0).toDouble(),
      stock: map['stock'] ?? 0,
      category: map['category'],
      imageUrl: map['imageUrl'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userId': userId,
      'barcode': barcode,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'stock': stock,
      'category': category,
      'imageUrl': imageUrl,
      'description': description,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
