import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ocam_pos/core/network/exceptions.dart';
import 'package:ocam_pos/core/network/firestore_paths.dart';
import 'package:ocam_pos/data/datasources/expense_remote_datasource.dart';
import 'package:ocam_pos/data/models/expense_model.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore db;
  late FirestorePaths paths;
  late ExpenseRemoteDataSourceImpl dataSource;

  setUp(() {
    db = FakeFirebaseFirestore();

    final auth = MockFirebaseAuth();
    final user = MockUser();
    when(() => user.uid).thenReturn('shop-1');
    when(() => auth.currentUser).thenReturn(user);

    paths = FirestorePaths(db: db, auth: auth);
    dataSource = ExpenseRemoteDataSourceImpl(paths: paths);
  });

  ExpenseModel expense({double amount = 50000, bool fromDrawer = true}) =>
      ExpenseModel(
        id: '',
        title: 'Dekabr ijarasi',
        category: 'Ijara',
        amount: amount,
        fromDrawer: fromDrawer,
        createdAt: DateTime.now(),
      );

  Future<double> drawerBalance() async {
    final doc = await paths.drawer.get();
    return (doc.data()?['current_balance'] as num?)?.toDouble() ?? 0;
  }

  group('addExpense', () {
    test('kassadan to\'langan xarajat kassani kamaytiradi', () async {
      await paths.drawer.set({'current_balance': 200000});

      final id = await dataSource.addExpense(expense());

      expect(await drawerBalance(), 150000);
      final doc = await paths.expenses.doc(id).get();
      expect(doc.data()!['title'], 'Dekabr ijarasi');
      expect(doc.data()!['fromDrawer'], isTrue);
      expect(doc.data()!['createdAt'], isNotNull);
    });

    test('kassadan to\'lanmagan xarajat balansga tegmaydi', () async {
      await paths.drawer.set({'current_balance': 200000});

      await dataSource.addExpense(expense(fromDrawer: false));

      expect(await drawerBalance(), 200000);
      expect((await paths.expenses.get()).docs, hasLength(1));
    });

    test('kassada pul yetmasa xarajat yozilmaydi', () async {
      await paths.drawer.set({'current_balance': 10000});

      await expectLater(
        dataSource.addExpense(expense()),
        throwsA(isA<ValidationException>()),
      );

      expect(await drawerBalance(), 10000);
      expect((await paths.expenses.get()).docs, isEmpty);
    });

    test('summa 0 bo\'lsa rad etiladi', () async {
      await expectLater(
        dataSource.addExpense(expense(amount: 0)),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('deleteExpense', () {
    test('kassadan to\'langan xarajat o\'chirilsa pul qaytariladi', () async {
      await paths.drawer.set({'current_balance': 200000});
      final id = await dataSource.addExpense(expense());

      await dataSource.deleteExpense(id);

      expect(await drawerBalance(), 200000);
      expect((await paths.expenses.get()).docs, isEmpty);
    });

    test('kassadan to\'lanmagan xarajat o\'chirilsa balans o\'zgarmaydi',
        () async {
      await paths.drawer.set({'current_balance': 200000});
      final id = await dataSource.addExpense(expense(fromDrawer: false));

      await dataSource.deleteExpense(id);

      expect(await drawerBalance(), 200000);
    });

    test('mavjud bo\'lmagan xarajat uchun xato', () async {
      await expectLater(
        dataSource.deleteExpense('yoq-id'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
