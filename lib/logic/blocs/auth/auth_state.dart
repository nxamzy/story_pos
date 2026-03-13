import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

// 1. Dastlabki holat
class AuthInitial extends AuthState {}

// 2. Yuklanish holati (Tugma bosilganda)
class AuthLoading extends AuthState {}

// 3. Muvaffaqiyatli kirish/ro'yxatdan o'tish
class Authenticated extends AuthState {
  final String uid;
  const Authenticated(this.uid);
  @override
  List<Object?> get props => [uid];
}

// 4. Tizimdan chiqib ketgan holat
class UnAuthenticated extends AuthState {}

// 5. Xatolik holati
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
