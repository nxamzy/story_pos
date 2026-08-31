import 'package:equatable/equatable.dart';
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
