import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<User?>? _userSubscription;

  AuthBloc() : super(AuthInitial()) {
    _userSubscription = _auth.authStateChanges().listen((user) {
      add(AuthStatusChanged(user));
    });

    on<AuthStatusChanged>((event, emit) {
      if (event.user != null) {
        emit(Authenticated(event.user!.uid));
      } else {
        emit(UnAuthenticated());
      }
    });

    on<SignUpRequested>((event, emit) async {
      if (event.email.isEmpty ||
          event.password.isEmpty ||
          event.firstName.isEmpty) {
        emit(const AuthError("Iltimos, barcha maydonlarni to'ldiring!"));
        return;
      }
      emit(AuthLoading());
      try {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
              email: event.email,
              password: event.password,
            );

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': event.email,
          'firstName': event.firstName,
          'lastName': event.lastName,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } on FirebaseAuthException catch (e) {
        emit(AuthError(_mapAuthError(e.code)));
      } catch (e) {
        emit(AuthError("Kutilmagan xato yuz berdi: $e"));
      }
    });

    on<SignInRequested>((event, emit) async {
      if (event.email.isEmpty || event.password.isEmpty) {
        emit(const AuthError("Email va parolni kiriting!"));
        return;
      }
      emit(AuthLoading());
      try {
        await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
      } on FirebaseAuthException catch (e) {
        emit(AuthError(_mapAuthError(e.code)));
      } catch (e) {
        emit(const AuthError("Tizimga kirishda xato yuz berdi!"));
      }
    });

    on<SignOutRequested>((event, emit) async {
      await _auth.signOut();
    });
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return "Bu email allaqachon band!";
      case 'weak-password':
        return "Parol juda zaif!";
      case 'user-not-found':
        return "Foydalanuvchi topilmadi!";
      case 'wrong-password':
        return "Parol noto'g'ri!";
      case 'invalid-email':
        return "Email formati xato!";
      default:
        return "Xatolik yuz berdi: $code";
    }
  }
}
