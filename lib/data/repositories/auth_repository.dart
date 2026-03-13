import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Sign Up (Ro'yxatdan o'tish)
  Future<void> signUp({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Firebase xatolarini tutish
      throw e.code;
    } catch (e) {
      // Boshqa kutilmagan xatolar
      throw "unknown-error";
    }
  }

  // Sign Out (Chiqish)
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
