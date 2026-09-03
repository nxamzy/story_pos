import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ocam_pos/core/network/firestore_paths.dart';
import 'package:ocam_pos/data/datasources/customer_remote_datasource.dart';
import 'package:ocam_pos/data/models/customer_model.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore db;
  late FirestorePaths paths;
  late CustomerRemoteDataSourceImpl dataSource;

  setUp(() {
    db = FakeFirebaseFirestore();

    final auth = MockFirebaseAuth();
    final user = MockUser();
    when(() => user.uid).thenReturn('shop-1');
    when(() => auth.currentUser).thenReturn(user);

    paths = FirestorePaths(db: db, auth: auth);
    dataSource = CustomerRemoteDataSourceImpl(paths: paths);
  });

  CustomerModel yangiMijoz() => CustomerModel(
    id: '',
    name: 'Anvar',
    phone: '901234567',
    altPhone: '937654321',
    email: 'anvar@example.com',
    createdAt: DateTime(2026),
  );

  test('yangi mijoz barcha maydonlari bilan saqlanadi', () async {
    final id = await dataSource.addCustomer(yangiMijoz());
    final doc = await paths.customers.doc(id).get();

    expect(doc.data()!['name'], 'Anvar');
    expect(doc.data()!['altPhone'], '937654321');
    expect(doc.data()!['email'], 'anvar@example.com');
    expect(doc.data()!['createdAt'], isNotNull);
  });

  test('mijozni tahrirlash ro\'yxatdan o\'tgan sanasini o\'zgartirmaydi', () async {
    final id = await dataSource.addCustomer(yangiMijoz());
    final createdAt = (await paths.customers.doc(id).get()).data()!['createdAt'];

    await dataSource.addCustomer(
      yangiMijoz().copyWith(id: id, name: 'Anvar Yusupov'),
    );

    final doc = await paths.customers.doc(id).get();
    expect(doc.data()!['name'], 'Anvar Yusupov');
    expect(doc.data()!['createdAt'], createdAt);
  });
}
