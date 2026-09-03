import 'package:equatable/equatable.dart';
import 'package:ocam_pos/data/models/model_utils.dart';

class CustomerModel extends Equatable {
  final String id;
  final String name;
  final String phone;

  /// Qo'shimcha telefon raqami. Formada "Qo'shimcha telefon qo'shish"
  /// tugmasi bor edi, lekin kiritilgan raqam hech qayerga yozilmasdi.
  final String altPhone;
  final String email;
  final String address;
  final String notes;
  final double totalSpent;
  final DateTime createdAt;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.altPhone = '',
    this.email = '',
    this.address = '',
    this.notes = '',
    this.totalSpent = 0,
    required this.createdAt,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map, String docId) {
    return CustomerModel(
      id: docId,
      name: ModelUtils.toStr(map['name']),
      phone: ModelUtils.toStr(map['phone']),
      altPhone: ModelUtils.toStr(map['altPhone']),
      email: ModelUtils.toStr(map['email']),
      address: ModelUtils.toStr(map['address']),
      notes: ModelUtils.toStr(map['notes']),
      totalSpent: ModelUtils.toDouble(map['totalSpent']),
      createdAt: ModelUtils.date(map['createdAt']),
    );
  }

  /// Diqqat: bu yerda barcha maydonlar yoziladi. Ilgari `email`, `address`
  /// va `notes` yozilmay qolib ketardi — shuning uchun mijoz saqlangach
  /// bu maydonlar bo'sh ko'rinardi.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'altPhone': altPhone,
      'email': email,
      'address': address,
      'notes': notes,
      'totalSpent': totalSpent,
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? altPhone,
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
      altPhone: altPhone ?? this.altPhone,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      totalSpent: totalSpent ?? this.totalSpent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    altPhone,
    email,
    address,
    notes,
    totalSpent,
  ];
}
