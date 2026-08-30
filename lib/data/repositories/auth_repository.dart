import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocam_pos/data/datasources/auth_remote_datasource.dart';
import 'package:ocam_pos/data/repositories/repository_guard.dart';

class AuthRepository with RepositoryGuard {
  final AuthRemoteDataSource _remote;

  AuthRepository({required AuthRemoteDataSource remote}) : _remote = remote;

  Stream<User?> authStateChanges() => _remote.authStateChanges();

  User? get currentUser => _remote.currentUser;

  bool get isSignedIn => _remote.currentUser != null;

  Future<void> signIn({required String email, required String password}) =>
      guard(() => _remote.signIn(email: email, password: password));

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) => guard(
    () => _remote.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    ),
  );

  Future<void> signOut() => guard(() => _remote.signOut());

  Future<void> sendPasswordResetEmail(String email) =>
      guard(() => _remote.sendPasswordResetEmail(email));

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => guard(
    () => _remote.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    ),
  );
}
