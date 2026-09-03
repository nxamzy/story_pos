import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ocam_pos/core/network/exceptions.dart';
import 'package:ocam_pos/core/network/firestore_paths.dart';
import 'package:ocam_pos/data/datasources/sale_remote_datasource.dart';
import 'package:ocam_pos/data/models/cart_item_model.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'package:ocam_pos/data/models/sale_model.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore db;
  late FirestorePaths paths;
  late SaleRemoteDataSourceImpl dataSource;

  setUp(() {
    db = FakeFirebaseFirestore();

    final auth = MockFirebaseAuth();
    final user = MockUser();
    when(() => user.uid).thenReturn('shop-1');
    when(() => auth.currentUser).thenReturn(user);

    paths = FirestorePaths(db: db, auth: auth);
    dataSource = SaleRemoteDataSourceImpl(paths: paths);
  });

  Future<ProductModel> addProduct({int stock = 10}) async {
    final doc = paths.products.doc('p1');
    await doc.set({
      'name': 'Coca-Cola',
      'barcode': '123',
      'buyPrice': 5000,
      'sellPrice': 8000,
      'stock': stock,
      'createdAt': Timestamp.fromDate(DateTime(2026)),
    });
    final snap = await doc.get();
    return ProductModel.fromMap(snap.data()!, doc.id);
  }

  SaleModel saleOf(ProductModel product, {int quantity = 2, DateTime? date}) {
    final items = [CartItem(product: product, quantity: quantity)];
    final total = product.sellPrice * quantity;
    return SaleModel(
      id: '',
      items: items,
      subTotal: total,
      total: total,
      paid: total,
      change: 0,
      createdAt: date ?? DateTime.now(),
    );
  }

  test('savdo omborni kamaytiradi va kassani to\'ldiradi', () async {
    final product = await addProduct(stock: 10);

    await dataSource.createSale(saleOf(product));

    final updated = await paths.products.doc(product.id).get();
    expect(updated.data()!['stock'], 8);

    final drawer = await paths.drawer.get();
    expect(drawer.data()!['current_balance'], 16000);
  });

  test('qoldiq yetmasa savdo ham, ombor ham o\'zgarmaydi', () async {
    final product = await addProduct(stock: 1);

    await expectLater(
      dataSource.createSale(saleOf(product, quantity: 5)),
      throwsA(isA<ValidationException>()),
    );

    final updated = await paths.products.doc(product.id).get();
    expect(updated.data()!['stock'], 1);
    expect((await paths.sales.get()).docs, isEmpty);
  });

  test('bugungi savdo server vaqti bilan yoziladi', () async {
    final product = await addProduct();

    await dataSource.createSale(saleOf(product));

    final sale = (await paths.sales.get()).docs.first;
    expect(sale.data()['createdAt'], isNotNull);
  });

  test('kassir tanlagan o\'tgan sana saqlanadi', () async {
    final product = await addProduct();
    final kecha = DateTime.now().subtract(const Duration(days: 1));

    await dataSource.createSale(saleOf(product, date: kecha));

    final sale = (await paths.sales.get()).docs.first;
    final saved = (sale.data()['createdAt'] as Timestamp).toDate();

    expect(saved.year, kecha.year);
    expect(saved.month, kecha.month);
    expect(saved.day, kecha.day);
  });

  group('refundSale', () {
    test('ombor tiklanadi, kassadan pul yechiladi', () async {
      final product = await addProduct(stock: 10);
      final saleId = await dataSource.createSale(saleOf(product, quantity: 2));

      // Savdodan keyingi holat: 8 dona qoldiq, kassada 16 000.
      await dataSource.refundSale(saleId);

      final updated = await paths.products.doc(product.id).get();
      expect(updated.data()!['stock'], 10);

      final drawer = await paths.drawer.get();
      expect(drawer.data()!['current_balance'], 0);

      final sale = await paths.sales.doc(saleId).get();
      expect(sale.data()!['refunded'], isTrue);
      expect(sale.data()!['refundedAt'], isNotNull);
    });

    test('bir savdoni ikki marta qaytarib bo\'lmaydi', () async {
      final product = await addProduct(stock: 10);
      final saleId = await dataSource.createSale(saleOf(product));

      await dataSource.refundSale(saleId);

      await expectLater(
        dataSource.refundSale(saleId),
        throwsA(isA<ValidationException>()),
      );

      // Ombor ikki marta oshib ketmagan.
      final updated = await paths.products.doc(product.id).get();
      expect(updated.data()!['stock'], 10);
    });

    test('kassada pul qolmagan bo\'lsa qaytarish rad etiladi', () async {
      final product = await addProduct(stock: 10);
      final saleId = await dataSource.createSale(saleOf(product));

      // Pul kassadan chiqarib yuborilgan holat.
      await paths.drawer.set({'current_balance': 0});

      await expectLater(
        dataSource.refundSale(saleId),
        throwsA(isA<ValidationException>()),
      );

      final sale = await paths.sales.doc(saleId).get();
      expect(sale.data()!['refunded'], isFalse);
      final updated = await paths.products.doc(product.id).get();
      expect(updated.data()!['stock'], 8);
    });

    test('mavjud bo\'lmagan savdo uchun xato', () async {
      await expectLater(
        dataSource.refundSale('yoq-id'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  test('bo\'sh savatni yakunlab bo\'lmaydi', () async {
    final bosh = SaleModel(
      id: '',
      items: const [],
      subTotal: 0,
      total: 0,
      paid: 0,
      change: 0,
      createdAt: DateTime.now(),
    );

    await expectLater(
      dataSource.createSale(bosh),
      throwsA(isA<ValidationException>()),
    );
  });
}
