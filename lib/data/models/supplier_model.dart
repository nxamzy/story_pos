import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:ocam_pos/data/models/model_utils.dart';

class SupplierModel extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String notes;
  final String imageUrl;
  final DateTime createdAt;

  const SupplierModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.address = '',
    this.notes = '',
    this.imageUrl = '',
    required this.createdAt,
  });

  factory SupplierModel.fromMap(Map<String, dynamic> map, String docId) {
    return SupplierModel(
      id: docId,
      name: ModelUtils.toStr(map['name']),
      phone: ModelUtils.toStr(map['phone']),
      email: ModelUtils.toStr(map['email']),
      address: ModelUtils.toStr(map['address']),
      notes: ModelUtils.toStr(map['notes']),
      imageUrl: ModelUtils.toStr(map['imageUrl']),
      // `serverTimestamp()` yozilgan zahoti lokal snapshot'da null keladi —
      // ilgari shu yerda `as Timestamp` cast qilinib, ilova yiqilardi.
      createdAt: ModelUtils.date(map['createdAt']),
    );
  }

  factory SupplierModel.fromFirestore(DocumentSnapshot doc) =>
      SupplierModel.fromMap(
        (doc.data() as Map<String, dynamic>?) ?? const {},
        doc.id,
      );

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'notes': notes,
      'imageUrl': imageUrl,
    };
  }

  SupplierModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? notes,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, email, address, notes, imageUrl];
}
