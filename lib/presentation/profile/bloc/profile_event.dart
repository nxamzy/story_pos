import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends ProfileEvent {
  const LoadUserProfile();
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
