import 'package:ocam_pos/data/datasources/user_remote_datasource.dart';
import 'package:ocam_pos/data/models/user_model.dart';
import 'package:ocam_pos/data/repositories/repository_guard.dart';

class UserRepository with RepositoryGuard {
  final UserRemoteDataSource _remote;

  UserRepository({required UserRemoteDataSource remote}) : _remote = remote;

  Stream<UserModel> watchProfile() => guardStream(_remote.watchProfile);

  Future<UserModel> getProfile() => guard(_remote.getProfile);

  Future<void> updateProfile(UserModel user) =>
      guard(() => _remote.updateProfile(user));
}
