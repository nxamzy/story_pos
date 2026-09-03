import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ocam_pos/core/network/exceptions.dart';
import 'package:ocam_pos/core/network/firestore_paths.dart';
import 'package:ocam_pos/data/datasources/employee_remote_datasource.dart';
import 'package:ocam_pos/data/models/employee_model.dart';
import 'package:ocam_pos/data/models/transfer_party_model.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore db;
  late FirestorePaths paths;
  late EmployeeRemoteDataSourceImpl dataSource;

  const uid = 'shop-1';

  setUp(() {
    db = FakeFirebaseFirestore();

    final auth = MockFirebaseAuth();
    final user = MockUser();
    when(() => user.uid).thenReturn(uid);
    when(() => auth.currentUser).thenReturn(user);

    paths = FirestorePaths(db: db, auth: auth);
    dataSource = EmployeeRemoteDataSourceImpl(paths: paths);
  });

  Future<EmployeeModel> addEmployee({
    required String name,
    double balance = 0,
  }) async {
    final id = await dataSource.addEmployee(
      EmployeeModel(
        id: '',
        name: name,
        role: 'Kassir',
        phone: '901234567',
        balance: balance,
        createdAt: DateTime(2026),
      ),
    );
    final doc = await paths.employees.doc(id).get();
    return EmployeeModel.fromMap(doc.data()!, id);
  }

  Future<double> drawerBalance() async {
    final doc = await paths.drawer.get();
    return (doc.data()?['current_balance'] as num?)?.toDouble() ?? 0;
  }

  group('transferBalance', () {
    test('kassadan xodimga pul beradi va ikkala balansni yangilaydi', () async {
      await paths.drawer.set({'current_balance': 500000});
      final aziz = await addEmployee(name: 'Aziz');

      await dataSource.transferBalance(
        from: TransferParty.drawer(500000),
        to: TransferParty.fromEmployee(aziz),
        amount: 120000,
        note: 'Maosh avansi',
      );

      expect(await drawerBalance(), 380000);
      final updated = await paths.employees.doc(aziz.id).get();
      expect(updated.data()!['balance'], 120000);

      final logs = await paths.transferLogs.get();
      expect(logs.docs, hasLength(1));
      expect(logs.docs.first.data()['from_id'], TransferParty.drawerId);
      expect(logs.docs.first.data()['to_name'], 'Aziz');
      expect(logs.docs.first.data()['amount'], 120000);
    });

    test('xodimdan kassaga qaytarilgan pul kassaga qo\'shiladi', () async {
      await paths.drawer.set({'current_balance': 100000});
      final aziz = await addEmployee(name: 'Aziz', balance: 70000);

      await dataSource.transferBalance(
        from: TransferParty.fromEmployee(aziz),
        to: TransferParty.drawer(100000),
        amount: 70000,
        note: '',
      );

      expect(await drawerBalance(), 170000);
      final updated = await paths.employees.doc(aziz.id).get();
      expect(updated.data()!['balance'], 0);
    });

    test('kassa hujjati hali yo\'q bo\'lsa ham qabul qila oladi', () async {
      final aziz = await addEmployee(name: 'Aziz', balance: 30000);

      await dataSource.transferBalance(
        from: TransferParty.fromEmployee(aziz),
        to: TransferParty.drawer(0),
        amount: 30000,
        note: '',
      );

      expect(await drawerBalance(), 30000);
    });

    test('mablag\' yetmasa hech narsa o\'zgarmaydi', () async {
      await paths.drawer.set({'current_balance': 10000});
      final aziz = await addEmployee(name: 'Aziz');

      await expectLater(
        dataSource.transferBalance(
          from: TransferParty.drawer(10000),
          to: TransferParty.fromEmployee(aziz),
          amount: 50000,
          note: '',
        ),
        throwsA(isA<ValidationException>()),
      );

      expect(await drawerBalance(), 10000);
      final updated = await paths.employees.doc(aziz.id).get();
      expect(updated.data()!['balance'], 0);
      expect((await paths.transferLogs.get()).docs, isEmpty);
    });

    test('o\'ziga o\'tkazma rad etiladi', () async {
      await expectLater(
        dataSource.transferBalance(
          from: TransferParty.drawer(10000),
          to: TransferParty.drawer(10000),
          amount: 1000,
          note: '',
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('addEmployee', () {
    test('yangi xodimga createdAt yoziladi', () async {
      final aziz = await addEmployee(name: 'Aziz');
      final doc = await paths.employees.doc(aziz.id).get();

      expect(doc.data()!['createdAt'], isNotNull);
    });

    test('mavjud xodim saqlanganda createdAt qayta yozilmaydi', () async {
      final aziz = await addEmployee(name: 'Aziz');
      final createdAt = (await paths.employees.doc(aziz.id).get())
          .data()!['createdAt'];

      await dataSource.addEmployee(aziz.copyWith(name: 'Aziz Karimov'));

      final doc = await paths.employees.doc(aziz.id).get();
      expect(doc.data()!['name'], 'Aziz Karimov');
      expect(doc.data()!['createdAt'], createdAt);
    });
  });
}
