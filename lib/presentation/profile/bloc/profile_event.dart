import 'package:equatable/equatable.dart';
import 'package:ocam_pos/core/utils/receipt_paper.dart';
import 'package:ocam_pos/data/models/user_model.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends ProfileEvent {
  const LoadUserProfile();
}

class ProfileUpdated extends ProfileEvent {
  final UserModel user;

  const ProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileFailed extends ProfileEvent {
  final String message;

  const ProfileFailed(this.message);

  @override
  List<Object?> get props => [message];
}

class UpdateUserProfile extends ProfileEvent {
  final String firstName;
  final String lastName;
  final String phone;

  const UpdateUserProfile({
    required this.firstName,
    required this.lastName,
    this.phone = '',
  });

  @override
  List<Object?> get props => [firstName, lastName, phone];
}

/// Do'kon ma'lumotlari (Sozlamalar sahifasidan). Faqat berilgan maydon
/// yangilanadi — qolganlari o'zgarmaydi.
class UpdateStoreInfo extends ProfileEvent {
  final String? storeName;
  final String? storePhone;
  final String? address;
  final String? taxId;
  final String? currency;
  final ReceiptPaper? receiptPaper;
  final bool? scannerHaptics;
  final int? lowStockThreshold;
  final bool? use24HourFormat;

  const UpdateStoreInfo({
    this.storeName,
    this.storePhone,
    this.address,
    this.taxId,
    this.currency,
    this.receiptPaper,
    this.scannerHaptics,
    this.lowStockThreshold,
    this.use24HourFormat,
  });

  @override
  List<Object?> get props => [
    storeName,
    storePhone,
    address,
    taxId,
    currency,
    receiptPaper,
    scannerHaptics,
    lowStockThreshold,
    use24HourFormat,
  ];
}
