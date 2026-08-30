import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/network/failure.dart';
import 'package:ocam_pos/core/utils/validators.dart';
import 'package:ocam_pos/data/repositories/auth_repository.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_event.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_state.dart';

/// Sessiya va autentifikatsiya bilan bog'liq barcha mantiq.
///
/// Firebase to'g'ridan-to'g'ri chaqirilmaydi — faqat [AuthRepository] orqali.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _userSubscription;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthStatusChanged>(_onStatusChanged);
    on<SignInRequested>(_onSignIn);
    on<SignUpRequested>(_onSignUp);
    on<SignOutRequested>(_onSignOut);
    on<PasswordResetRequested>(_onPasswordReset);
    on<PasswordChangeRequested>(_onPasswordChange);
    on<AuthMessageCleared>(
      (event, emit) => emit(
        state.copyWith(action: AuthActionStatus.idle, clearMessage: true),
      ),
    );

    add(const AuthStarted());
  }

  void _onStarted(AuthStarted event, Emitter<AuthState> emit) {
    _userSubscription?.cancel();
    _userSubscription = _authRepository.authStateChanges().listen(
      (user) => add(AuthStatusChanged(user)),
    );
  }

  void _onStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) {
    final user = event.user;
    emit(
      state.copyWith(
        status: user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        uid: user?.uid,
        clearUid: user == null,
        action: AuthActionStatus.idle,
        clearMessage: true,
      ),
    );
  }

  Future<void> _onSignIn(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    final validation =
        Validators.email(event.email) ??
        Validators.required(event.password, "Parol");
    if (validation != null) return _fail(emit, validation);

    emit(state.copyWith(action: AuthActionStatus.loading, clearMessage: true));
    try {
      await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      // Muvaffaqiyat bo'lsa `authStateChanges` o'zi `AuthStatusChanged`
      // yuboradi — shuning uchun bu yerda qo'shimcha emit shart emas.
    } catch (error) {
      _fail(emit, Failure.from(error).message);
    }
  }

  Future<void> _onSignUp(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    final validation =
        Validators.required(event.firstName, "Ism") ??
        Validators.email(event.email) ??
        Validators.password(event.password);
    if (validation != null) return _fail(emit, validation);

    emit(state.copyWith(action: AuthActionStatus.loading, clearMessage: true));
    try {
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
      );
    } catch (error) {
      _fail(emit, Failure.from(error).message);
    }
  }

  Future<void> _onSignOut(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.signOut();
    } catch (error) {
      _fail(emit, Failure.from(error).message);
    }
  }

  Future<void> _onPasswordReset(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    final validation = Validators.email(event.email);
    if (validation != null) return _fail(emit, validation);

    emit(state.copyWith(action: AuthActionStatus.loading, clearMessage: true));
    try {
      await _authRepository.sendPasswordResetEmail(event.email);
      emit(
        state.copyWith(
          action: AuthActionStatus.success,
          message: "Parolni tiklash havolasi emailingizga yuborildi",
        ),
      );
    } catch (error) {
      _fail(emit, Failure.from(error).message);
    }
  }

  Future<void> _onPasswordChange(
    PasswordChangeRequested event,
    Emitter<AuthState> emit,
  ) async {
    final validation = Validators.password(event.newPassword);
    if (validation != null) return _fail(emit, validation);

    emit(state.copyWith(action: AuthActionStatus.loading, clearMessage: true));
    try {
      await _authRepository.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      emit(
        state.copyWith(
          action: AuthActionStatus.success,
          message: "Parol muvaffaqiyatli o'zgartirildi",
        ),
      );
    } catch (error) {
      _fail(emit, Failure.from(error).message);
    }
  }

  void _fail(Emitter<AuthState> emit, String message) => emit(
    state.copyWith(action: AuthActionStatus.failure, message: message),
  );

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
