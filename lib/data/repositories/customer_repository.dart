import 'package:ocam_pos/data/datasources/customer_remote_datasource.dart';
import 'package:ocam_pos/data/models/customer_model.dart';
import 'package:ocam_pos/data/repositories/repository_guard.dart';

class CustomerRepository with RepositoryGuard {
  final CustomerRemoteDataSource _remote;

  CustomerRepository({required CustomerRemoteDataSource remote})
    : _remote = remote;

  Stream<List<CustomerModel>> watchCustomers() =>
      guardStream(_remote.watchCustomers);

  Future<String> addCustomer(CustomerModel customer) =>
      guard(() => _remote.addCustomer(customer));

  Future<void> updateCustomer(CustomerModel customer) =>
      guard(() => _remote.updateCustomer(customer));

  Future<void> deleteCustomer(String id) =>
      guard(() => _remote.deleteCustomer(id));
}
