import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Ilova ochilganda sessiyani kuzatishni boshlaydi.
class AuthStarted extends AuthEvent {
  const AuthStarted();
}

/// Firebase sessiya holati o'zgarganda ichkarida yuboriladi.
class AuthStatusChanged extends AuthEvent {
  final User? user;
  const AuthStatusChanged(this.user);

  @override
  List<Object?> get props => [user?.uid];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  const SignUpRequested(
    this.email,
    this.password,
    this.firstName,
    this.lastName,
  );

  @override
  List<Object?> get props => [email, password, firstName, lastName];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class PasswordResetRequested extends AuthEvent {
  final String email;
  const PasswordResetRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class PasswordChangeRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const PasswordChangeRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

/// Ko'rsatilgan xato/xabar o'qildi — state'dan tozalanadi.
class AuthMessageCleared extends AuthEvent {
  const AuthMessageCleared();
}
