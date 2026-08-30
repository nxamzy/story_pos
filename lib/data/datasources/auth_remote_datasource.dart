import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocam_pos/core/network/exceptions.dart';
import 'package:ocam_pos/core/network/firestore_paths.dart';
import 'package:ocam_pos/data/models/user_model.dart';

/// Autentifikatsiya bilan ishlash shartnomasi.
/// Backend almashsa — faqat shu interfeysning yangi implementatsiyasi yoziladi.
abstract class AuthRemoteDataSource {
  Stream<User?> authStateChanges();
  User? get currentUser;

  Future<void> signIn({required String email, required String password});
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirestorePaths _paths;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth auth,
    required FirestorePaths paths,
  }) : _auth = auth,
       _paths = paths;

  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw const AuthException("Hisob yaratildi, lekin ma'lumot olinmadi");
    }

    final profile = UserModel(
      uid: user.uid,
      email: email.trim(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
    );

    await _paths.userDoc.set({
      ...profile.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw const UnauthenticatedException();
    }

    // Parolni o'zgartirishdan oldin Firebase qayta tasdiqlashni talab qiladi.
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      ),
    );
    await user.updatePassword(newPassword);
  }
}
