import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocam_pos/core/network/exceptions.dart';
import 'package:ocam_pos/core/network/firestore_paths.dart';
import 'package:ocam_pos/data/models/user_model.dart';

abstract class UserRemoteDataSource {
  Stream<UserModel> watchProfile();
  Future<UserModel> getProfile();
  Future<void> updateProfile(UserModel user);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirestorePaths _paths;

  UserRemoteDataSourceImpl({required FirestorePaths paths}) : _paths = paths;

  @override
  Stream<UserModel> watchProfile() => _paths.userDoc.snapshots().map((doc) {
    if (!doc.exists) throw const NotFoundException("Profil topilmadi");
    return UserModel.fromMap(doc.data() ?? const {}, doc.id);
  });

  @override
  Future<UserModel> getProfile() async {
    final doc = await _paths.userDoc.get();
    if (!doc.exists) throw const NotFoundException("Profil topilmadi");
    return UserModel.fromMap(doc.data() ?? const {}, doc.id);
  }

  @override
  Future<void> updateProfile(UserModel user) =>
      _paths.userDoc.set(user.toMap(), SetOptions(merge: true));
}
