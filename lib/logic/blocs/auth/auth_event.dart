import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class SignUpRequested extends AuthEvent {
  final String email, password, firstName, lastName;
  const SignUpRequested(
    this.email,
    this.password,
    this.firstName,
    this.lastName,
  );
}

class SignInRequested extends AuthEvent {
  final String email, password;
  const SignInRequested(this.email, this.password);
}

class SignOutRequested extends AuthEvent {}

class AuthStatusChanged extends AuthEvent {
  final User? user;
  const AuthStatusChanged(this.user);

  @override
  List<Object?> get props => [user];
}
