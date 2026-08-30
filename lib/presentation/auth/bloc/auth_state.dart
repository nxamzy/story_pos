import 'package:equatable/equatable.dart';

/// Sessiya holati — router shu qiymatga qarab yo'naltiradi.
enum AuthStatus { unknown, authenticated, unauthenticated }

/// Foydalanuvchi bajargan amal holati (kirish, ro'yxatdan o'tish, ...).
enum AuthActionStatus { idle, loading, success, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthActionStatus action;
  final String? uid;
  final String? message;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.action = AuthActionStatus.idle,
    this.uid,
    this.message,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isLoading => action == AuthActionStatus.loading;
  bool get hasError => action == AuthActionStatus.failure;
  String? get errorMessage => hasError ? message : null;

  AuthState copyWith({
    AuthStatus? status,
    AuthActionStatus? action,
    String? uid,
    String? message,
    bool clearMessage = false,
    bool clearUid = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      action: action ?? this.action,
      uid: clearUid ? null : (uid ?? this.uid),
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, action, uid, message];
}
