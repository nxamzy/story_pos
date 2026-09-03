import 'package:equatable/equatable.dart';
import 'package:ocam_pos/core/utils/app_config.dart';
import 'package:ocam_pos/data/models/model_utils.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String? photoUrl;
  final String storeName;

  /// Do'konning aloqa raqami — foydalanuvchining shaxsiy raqamidan
  /// alohida (chekda va sozlamalarda shu ko'rsatiladi).
  final String storePhone;
  final String address;

  /// STIR (soliq to'lovchi identifikatsiya raqami).
  final String taxId;

  /// Do'kon valyutasi (masalan `UZS`). Bo'sh bo'lsa standart qiymat.
  final String currency;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.photoUrl,
    this.storeName = '',
    this.storePhone = '',
    this.address = '',
    this.taxId = '',
    this.currency = AppConfig.defaultCurrency,
    this.createdAt,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? email : name;
  }

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    final result = '$first$last'.trim().toUpperCase();
    return result.isEmpty ? '?' : result;
  }

  factory UserModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return UserModel(
      uid: ModelUtils.toStr(map['uid'], docId ?? ''),
      email: ModelUtils.toStr(map['email']),
      firstName: ModelUtils.toStr(map['firstName']),
      lastName: ModelUtils.toStr(map['lastName']),
      phone: ModelUtils.toStr(map['phone']),
      photoUrl: map['photoUrl'] as String?,
      storeName: ModelUtils.toStr(map['storeName']),
      storePhone: ModelUtils.toStr(map['storePhone']),
      address: ModelUtils.toStr(map['address']),
      taxId: ModelUtils.toStr(map['taxId']),
      currency: ModelUtils.toStr(map['currency'], AppConfig.defaultCurrency),
      createdAt: ModelUtils.dateOrNull(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'photoUrl': photoUrl,
      'storeName': storeName,
      'storePhone': storePhone,
      'address': address,
      'taxId': taxId,
      'currency': currency,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? photoUrl,
    String? storeName,
    String? storePhone,
    String? address,
    String? taxId,
    String? currency,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      storeName: storeName ?? this.storeName,
      storePhone: storePhone ?? this.storePhone,
      address: address ?? this.address,
      taxId: taxId ?? this.taxId,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    email,
    firstName,
    lastName,
    phone,
    photoUrl,
    storeName,
    storePhone,
    address,
    taxId,
    currency,
  ];
}
