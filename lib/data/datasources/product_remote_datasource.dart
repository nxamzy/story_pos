import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocam_pos/core/network/exceptions.dart';
import 'package:ocam_pos/core/network/firestore_paths.dart';
import 'package:ocam_pos/data/models/product_model.dart';

abstract class ProductRemoteDataSource {
  Stream<List<ProductModel>> watchProducts();
  Future<List<ProductModel>> getProducts({String? category});
  Future<ProductModel?> findByBarcode(String barcode);
  Future<String> addProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
  Future<List<String>> getCategories();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirestorePaths _paths;

  ProductRemoteDataSourceImpl({required FirestorePaths paths})
    : _paths = paths;

  @override
  Stream<List<ProductModel>> watchProducts() => _paths.products
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList(),
      );

  @override
  Future<List<ProductModel>> getProducts({String? category}) async {
    Query<Map<String, dynamic>> query = _paths.products;
    if (category != null && category.isNotEmpty && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    final snap = await query.get();
    return snap.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<ProductModel?> findByBarcode(String barcode) async {
    final snap = await _paths.products
        .where('barcode', isEqualTo: barcode.trim())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return ProductModel.fromMap(doc.data(), doc.id);
  }

  @override
  Future<String> addProduct(ProductModel product) async {
    if (product.barcode.isNotEmpty) {
      final existing = await findByBarcode(product.barcode);
      if (existing != null) {
        throw const ValidationException(
          "Bu shtrix-kod bilan mahsulot allaqachon mavjud",
        );
      }
    }

    final doc = _paths.products.doc();
    await doc.set({
      ...product.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  @override
  Future<void> updateProduct(ProductModel product) =>
      _paths.products.doc(product.id).update(product.toMap());

  @override
  Future<void> deleteProduct(String id) => _paths.products.doc(id).delete();

  @override
  Future<List<String>> getCategories() async {
    final snap = await _paths.products.get();
    final categories = snap.docs
        .map((doc) => (doc.data()['category'] as String?)?.trim() ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return categories;
  }
}
