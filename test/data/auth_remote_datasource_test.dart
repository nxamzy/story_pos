import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ocam_pos/core/network/firestore_paths.dart';
import 'package:ocam_pos/data/datasources/auth_remote_datasource.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  setUpAll(() => registerFallbackValue(FakeAuthCredential()));

  late FakeFirebaseFirestore db;
  late FirestorePaths paths;
  late MockFirebaseAuth auth;
  late MockUser user;
  late AuthRemoteDataSourceImpl dataSource;

  /// Do'konda har turdagi hujjatdan bittadan bo'lgan holat.
  Future<void> seedStore() async {
    await paths.userDoc.set({'email': 'egasi@ocam.uz', 'storeName': 'Ocam'});
    await paths.products.add({'name': 'Suv', 'stock': 10});
    await paths.customers.add({'name': 'Ali'});
    await paths.suppliers.add({'name': 'Omad savdo'});
    await paths.sales.add({'total': 25000});
    await paths.employees.add({'name': 'Kassir'});
    await paths.transferLogs.add({'amount': 5000});
    await paths.expenses.add({'title': 'Ijara'});
    await paths.purchases.add({'total': 90000});
    await paths.drawer.set({'current_balance': 120000});
  }

  /// Do'konda umuman hujjat qolmaganini tekshiradi.
  Future<int> remainingDocs() async {
    var count = 0;
    for (final collection in paths.allStoreCollections) {
      count += (await collection.get()).docs.length;
    }
    if ((await paths.userDoc.get()).exists) count++;
    return count;
  }

  setUp(() {
    db = FakeFirebaseFirestore();
    auth = MockFirebaseAuth();
    user = MockUser();

    when(() => user.uid).thenReturn('shop-1');
    when(() => user.email).thenReturn('egasi@ocam.uz');
    when(() => auth.currentUser).thenReturn(user);
    when(
      () => user.reauthenticateWithCredential(any()),
    ).thenAnswer((_) async => MockUserCredential());
    when(() => user.delete()).thenAnswer((_) async {});

    paths = FirestorePaths(db: db, auth: auth);
    dataSource = AuthRemoteDataSourceImpl(auth: auth, paths: paths);
  });

  group('AuthRemoteDataSource.deleteAccount', () {
    test("do'konning barcha ma'lumotini va hisobni o'chiradi", () async {
      await seedStore();
      expect(await remainingDocs(), 10);

      await dataSource.deleteAccount(password: 'parol123');

      expect(await remainingDocs(), 0);
      verify(() => user.delete()).called(1);
    });

    test("ma'lumot Firebase hisobidan OLDIN o'chiriladi", () async {
      await seedStore();

      // `user.delete()` chaqirilgan paytda hujjatlar allaqachon
      // o'chirilgan bo'lishi shart: hisob o'chgach sessiya tugaydi va
      // Firestore qoidalari yozishga ruxsat bermaydi.
      int? docsWhenAccountDeleted;
      when(() => user.delete()).thenAnswer((_) async {
        docsWhenAccountDeleted = await remainingDocs();
      });

      await dataSource.deleteAccount(password: 'parol123');

      expect(docsWhenAccountDeleted, 0);
    });

    test("parol noto'g'ri bo'lsa hech narsa o'chmaydi", () async {
      await seedStore();
      when(() => user.reauthenticateWithCredential(any())).thenThrow(
        FirebaseAuthException(code: 'wrong-password', message: "Parol xato"),
      );

      await expectLater(
        dataSource.deleteAccount(password: 'xato'),
        throwsA(isA<FirebaseAuthException>()),
      );

      expect(await remainingDocs(), 10);
      verifyNever(() => user.delete());
    });

    test("bitta bo'lakdan ko'p hujjat bo'lsa ham hammasi o'chadi", () async {
      await paths.userDoc.set({'email': 'egasi@ocam.uz'});
      // `_deleteCollection` 400 tadan o'chiradi — chegaradan oshgan holat.
      for (var i = 0; i < 405; i++) {
        await paths.products.add({'name': 'Mahsulot $i'});
      }

      await dataSource.deleteAccount(password: 'parol123');

      expect((await paths.products.get()).docs, isEmpty);
      expect(await remainingDocs(), 0);
    });
  });
}
