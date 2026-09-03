import 'package:ocam_pos/data/datasources/sale_remote_datasource.dart';
import 'package:ocam_pos/data/models/sale_model.dart';
import 'package:ocam_pos/data/repositories/repository_guard.dart';

class SaleRepository with RepositoryGuard {
  final SaleRemoteDataSource _remote;

  SaleRepository({required SaleRemoteDataSource remote}) : _remote = remote;

  Future<String> createSale(SaleModel sale) =>
      guard(() => _remote.createSale(sale));

  Stream<List<SaleModel>> watchSales({
    DateTime? from,
    DateTime? to,
    int? limit,
  }) => guardStream(() => _remote.watchSales(from: from, to: to, limit: limit));

  Future<List<SaleModel>> getSales({DateTime? from, DateTime? to}) =>
      guard(() => _remote.getSales(from: from, to: to));

  Future<List<SaleModel>> getSalesByCustomer(String customerId) =>
      guard(() => _remote.getSalesByCustomer(customerId));

  Future<void> refundSale(String saleId) =>
      guard(() => _remote.refundSale(saleId));

  Future<List<SaleModel>> getRefundedSales({int days = 30}) =>
      guard(() => _remote.getRefundedSales(days: days));
}
