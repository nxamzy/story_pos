import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String userId;
  final String barcode;
  final double buyPrice; // Sotib olingan narxi (tannarxi)
  final double sellPrice; // Sotish narxi
  final int stock; // Ombordagi soni
  final String? category;
  final String? imageUrl;
  final String? description; // 🔥 MANA SHU QATOR QO'SHILDI!

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
    this.description, // 🔥 Constructor-ga ham qo'shildi
  });

  // 🔥 1. Bazadan ma'lumot kelganda (Firestore -> App)
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
      description: map['description'], // 🔥 Map-dan o'qib olish
    );
  }

  // 🔥 2. Bazaga ma'lumot yuborganda (App -> Firestore)
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
      'description': description, // 🔥 Map-ga qo'shish
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
