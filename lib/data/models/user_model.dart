import 'package:equatable/equatable.dart';
import 'package:ocam_pos/data/models/model_utils.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String? photoUrl;
  final String storeName;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.photoUrl,
    this.storeName = '',
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
  ];
}
