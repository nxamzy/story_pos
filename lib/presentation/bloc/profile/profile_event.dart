import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends ProfileEvent {
  final String uid;
  const LoadUserProfile(this.uid);
  @override
  List<Object?> get props => [uid];
}

class UpdateUserProfile extends ProfileEvent {
  final String firstName;
  final String lastName;

  const UpdateUserProfile({required this.firstName, required this.lastName});

  @override
  List<Object?> get props => [firstName, lastName];
}
