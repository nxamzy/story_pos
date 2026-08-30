import 'package:ocam_pos/data/datasources/product_remote_datasource.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'package:ocam_pos/data/repositories/repository_guard.dart';

class ProductRepository with RepositoryGuard {
  final ProductRemoteDataSource _remote;

  ProductRepository({required ProductRemoteDataSource remote})
    : _remote = remote;

  Stream<List<ProductModel>> watchProducts() =>
      guardStream(_remote.watchProducts);

  Future<List<ProductModel>> getProducts({String? category}) =>
      guard(() => _remote.getProducts(category: category));

  Future<ProductModel?> findByBarcode(String barcode) =>
      guard(() => _remote.findByBarcode(barcode));

  Future<String> addProduct(ProductModel product) =>
      guard(() => _remote.addProduct(product));

  Future<void> updateProduct(ProductModel product) =>
      guard(() => _remote.updateProduct(product));

  Future<void> deleteProduct(String id) =>
      guard(() => _remote.deleteProduct(id));

  Future<List<String>> getCategories() => guard(_remote.getCategories);
}
