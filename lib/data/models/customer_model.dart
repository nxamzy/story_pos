import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String notes;
  final double totalSpent;
  final DateTime createdAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.notes,
    required this.totalSpent,
    required this.createdAt,
  });

  // 🔥 MANA SHU METODNI QO'SHISH KERAK:
  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? notes,
    double? totalSpent,
    DateTime? createdAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      totalSpent: totalSpent ?? this.totalSpent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // toMap va fromMap funksiyalaring pastda qolaversin...// Firestore-ga yozish uchun
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'totalSpent': totalSpent,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map, String docId) {
    return CustomerModel(
      id: docId,
      // 1. Emailni to'g'ri map'dan olamiz
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '', // Bu maydonni ham unutma!
      notes: map['notes'] ?? '', // Bu ham muhim!
      totalSpent: (map['totalSpent'] ?? 0.0).toDouble(),

      // 2. Sana bilan ishlash (Firestore Timestamp bo'lsa toDate() qilamiz)
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is String
                ? DateTime.parse(map['createdAt'])
                : (map['createdAt'] as Timestamp).toDate())
          : DateTime.now(),
    );
  }
}
