import 'package:ocam_pos/data/datasources/purchase_remote_datasource.dart';
import 'package:ocam_pos/data/models/purchase_model.dart';
import 'package:ocam_pos/data/repositories/repository_guard.dart';

class PurchaseRepository with RepositoryGuard {
  final PurchaseRemoteDataSource _remote;

  PurchaseRepository({required PurchaseRemoteDataSource remote})
    : _remote = remote;

  Stream<List<PurchaseModel>> watchPurchases({int limit = 50}) =>
      guardStream(() => _remote.watchPurchases(limit: limit));

  Future<String> createPurchase(PurchaseModel purchase) =>
      guard(() => _remote.createPurchase(purchase));
}
