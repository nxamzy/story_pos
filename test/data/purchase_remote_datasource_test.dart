import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ocam_pos/core/network/exceptions.dart';
import 'package:ocam_pos/core/network/firestore_paths.dart';
import 'package:ocam_pos/data/datasources/purchase_remote_datasource.dart';
import 'package:ocam_pos/data/models/purchase_model.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore db;
  late FirestorePaths paths;
  late PurchaseRemoteDataSourceImpl dataSource;

  setUp(() {
    db = FakeFirebaseFirestore();

    final auth = MockFirebaseAuth();
    final user = MockUser();
    when(() => user.uid).thenReturn('shop-1');
    when(() => auth.currentUser).thenReturn(user);

    paths = FirestorePaths(db: db, auth: auth);
    dataSource = PurchaseRemoteDataSourceImpl(paths: paths);
  });

  Future<void> addProduct({int stock = 5, double buyPrice = 5000}) async {
    await paths.products.doc('p1').set({
      'name': 'Coca-Cola',
      'barcode': '123',
      'buyPrice': buyPrice,
      'sellPrice': 8000,
      'stock': stock,
      'createdAt': Timestamp.fromDate(DateTime(2026)),
    });
  }

  PurchaseModel purchase({
    int quantity = 10,
    double buyPrice = 6000,
    bool paidFromDrawer = true,
    String productId = 'p1',
  }) => PurchaseModel(
    id: '',
    supplierId: 's1',
    supplierName: 'Ta\'minotchi A',
    items: [
      PurchaseItem(
        productId: productId,
        name: 'Coca-Cola',
        quantity: quantity,
        buyPrice: buyPrice,
      ),
    ],
    paidFromDrawer: paidFromDrawer,
    createdAt: DateTime.now(),
  );

  Future<double> drawerBalance() async {
    final doc = await paths.drawer.get();
    return (doc.data()?['current_balance'] as num?)?.toDouble() ?? 0;
  }

  test('xarid omborni to\'ldiradi va tannarxni yangilaydi', () async {
    await addProduct(stock: 5, buyPrice: 5000);
    await paths.drawer.set({'current_balance': 100000});

    await dataSource.createPurchase(purchase(quantity: 10, buyPrice: 6000));

    final product = await paths.products.doc('p1').get();
    expect(product.data()!['stock'], 15);
    // Tannarx oxirgi xariddagi narxga o'tadi — foyda hisobi shunga tayanadi.
    expect(product.data()!['buyPrice'], 6000);

    expect(await drawerBalance(), 40000);

    final saved = (await paths.purchases.get()).docs.first;
    expect(saved.data()['supplierName'], 'Ta\'minotchi A');
    expect(saved.data()['total'], 60000);
    expect(saved.data()['createdAt'], isNotNull);
  });

  test('qarzga olingan xarid kassaga tegmaydi', () async {
    await addProduct(stock: 5);
    await paths.drawer.set({'current_balance': 10000});

    await dataSource.createPurchase(
      purchase(quantity: 2, buyPrice: 6000, paidFromDrawer: false),
    );

    expect(await drawerBalance(), 10000);
    final product = await paths.products.doc('p1').get();
    expect(product.data()!['stock'], 7);
  });

  test('kassada pul yetmasa ombor ham o\'zgarmaydi', () async {
    await addProduct(stock: 5);
    await paths.drawer.set({'current_balance': 1000});

    await expectLater(
      dataSource.createPurchase(purchase(quantity: 10, buyPrice: 6000)),
      throwsA(isA<ValidationException>()),
    );

    final product = await paths.products.doc('p1').get();
    expect(product.data()!['stock'], 5);
    expect((await paths.purchases.get()).docs, isEmpty);
  });

  test('ombordan o\'chirilgan mahsulot uchun xarid yozilmaydi', () async {
    await paths.drawer.set({'current_balance': 100000});

    await expectLater(
      dataSource.createPurchase(purchase(productId: 'yoq')),
      throwsA(isA<ValidationException>()),
    );

    expect((await paths.purchases.get()).docs, isEmpty);
  });

  test('tannarx kiritilmagan bo\'lsa mahsulotning eski narxi saqlanadi',
      () async {
    await addProduct(stock: 5, buyPrice: 5000);
    await paths.drawer.set({'current_balance': 100000});

    await dataSource.createPurchase(purchase(quantity: 3, buyPrice: 0));

    final product = await paths.products.doc('p1').get();
    expect(product.data()!['stock'], 8);
    expect(product.data()!['buyPrice'], 5000);
  });

  test('bo\'sh xaridni saqlab bo\'lmaydi', () async {
    await expectLater(
      dataSource.createPurchase(
        PurchaseModel(
          id: '',
          supplierId: 's1',
          supplierName: 'A',
          items: const [],
          createdAt: DateTime.now(),
        ),
      ),
      throwsA(isA<ValidationException>()),
    );
  });
}
