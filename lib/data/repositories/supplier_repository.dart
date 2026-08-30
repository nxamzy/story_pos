import 'package:ocam_pos/data/datasources/supplier_remote_datasource.dart';
import 'package:ocam_pos/data/models/supplier_model.dart';
import 'package:ocam_pos/data/repositories/repository_guard.dart';

class SupplierRepository with RepositoryGuard {
  final SupplierRemoteDataSource _remote;

  SupplierRepository({required SupplierRemoteDataSource remote})
    : _remote = remote;

  Stream<List<SupplierModel>> watchSuppliers({DateTime? date}) =>
      guardStream(() => _remote.watchSuppliers(date: date));

  Future<String> addSupplier(SupplierModel supplier) =>
      guard(() => _remote.addSupplier(supplier));

  Future<void> updateSupplier(SupplierModel supplier) =>
      guard(() => _remote.updateSupplier(supplier));

  Future<void> deleteSupplier(String id) =>
      guard(() => _remote.deleteSupplier(id));
}
