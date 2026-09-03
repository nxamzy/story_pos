import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ocam_pos/data/models/employee_model.dart';
import 'package:ocam_pos/data/models/transfer_party_model.dart';
import 'package:ocam_pos/data/repositories/employee_repository.dart';
import 'package:ocam_pos/presentation/cashdrawer/bloc/cash_bloc.dart';
import 'package:ocam_pos/presentation/cashdrawer/bloc/cash_event.dart';
import 'package:ocam_pos/presentation/cashdrawer/bloc/cash_state.dart';

class MockEmployeeRepository extends Mock implements EmployeeRepository {}

class FakeTransferParty extends Fake implements TransferParty {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTransferParty());
  });

  late MockEmployeeRepository repository;

  final kassir = EmployeeModel(
    id: 'e1',
    name: 'Aziz',
    role: 'Kassir',
    phone: '901234567',
    balance: 50000,
    createdAt: DateTime(2026),
  );

  final menejer = EmployeeModel(
    id: 'e2',
    name: 'Dilnoza',
    role: 'Menejer',
    phone: '901234568',
    balance: 0,
    createdAt: DateTime(2026),
  );

  /// Kassada 200 000, ikkita xodim bor holat.
  CashState loadedState({String? fromId, String? toId}) => CashState(
    balance: 200000,
    employees: [kassir, menejer],
    fromId: fromId,
    toId: toId,
  );

  setUp(() {
    repository = MockEmployeeRepository();
  });

  CashBloc buildBloc() => CashBloc(repository: repository);

  group('CashState taraflari', () {
    test('kassa har doim birinchi taraf sifatida turadi', () {
      final parties = loadedState().parties;

      expect(parties.first.isDrawer, isTrue);
      expect(parties.first.balance, 200000);
      expect(parties.length, 3);
    });

    test('tanlangan taraf balansi ro\'yxatdan olinadi (eskirmaydi)', () {
      final state = loadedState(fromId: 'e1');

      expect(state.from?.name, 'Aziz');
      expect(state.from?.balance, 50000);

      // Balans o'zgargach tanlov ham yangi qiymatni ko'rsatadi.
      final updated = state.copyWith(
        employees: [kassir.copyWith(balance: 10000), menejer],
      );
      expect(updated.from?.balance, 10000);
    });
  });

  group('TransferRequested', () {
    blocTest<CashBloc, CashState>(
      'kassadan xodimga o\'tkazadi',
      build: () {
        when(
          () => repository.transferBalance(
            from: any(named: 'from'),
            to: any(named: 'to'),
            amount: any(named: 'amount'),
            note: any(named: 'note'),
          ),
        ).thenAnswer((_) async {});
        return buildBloc();
      },
      seed: () => loadedState(fromId: TransferParty.drawerId, toId: 'e1'),
      act: (bloc) => bloc.add(const TransferRequested(amount: '150000')),
      verify: (_) {
        final captured = verify(
          () => repository.transferBalance(
            from: captureAny(named: 'from'),
            to: captureAny(named: 'to'),
            amount: 150000,
            note: '',
          ),
        ).captured;

        expect((captured[0] as TransferParty).isDrawer, isTrue);
        expect((captured[1] as TransferParty).id, 'e1');
      },
    );

    blocTest<CashBloc, CashState>(
      'kassada yetarli pul bo\'lmasa yozmaydi',
      build: buildBloc,
      seed: () => loadedState(fromId: TransferParty.drawerId, toId: 'e1'),
      act: (bloc) => bloc.add(const TransferRequested(amount: '500000')),
      expect: () => [
        isA<CashState>().having(
          (s) => s.error,
          'error',
          "Kassada mablag' yetarli emas",
        ),
      ],
      verify: (_) => verifyNever(
        () => repository.transferBalance(
          from: any(named: 'from'),
          to: any(named: 'to'),
          amount: any(named: 'amount'),
          note: any(named: 'note'),
        ),
      ),
    );

    blocTest<CashBloc, CashState>(
      'bir xil tarafga o\'tkazishga yo\'l qo\'ymaydi',
      build: buildBloc,
      seed: () => loadedState(fromId: 'e1', toId: 'e1'),
      act: (bloc) => bloc.add(const TransferRequested(amount: '1000')),
      expect: () => [
        isA<CashState>().having(
          (s) => s.error,
          'error',
          "O'ziga o'tkazma qilib bo'lmaydi",
        ),
      ],
    );

    blocTest<CashBloc, CashState>(
      'taraf tanlanmagan bo\'lsa xato beradi',
      build: buildBloc,
      seed: () => loadedState(fromId: 'e1'),
      act: (bloc) => bloc.add(const TransferRequested(amount: '1000')),
      expect: () => [
        isA<CashState>().having(
          (s) => s.error,
          'error',
          "Yuboruvchi va qabul qiluvchini tanlang",
        ),
      ],
    );

    blocTest<CashBloc, CashState>(
      'summa 0 yoki manfiy bo\'lsa xato beradi',
      build: buildBloc,
      seed: () => loadedState(fromId: 'e1', toId: 'e2'),
      act: (bloc) => bloc.add(const TransferRequested(amount: '0')),
      expect: () => [
        isA<CashState>().having((s) => s.error, 'error', "To'g'ri summa kiriting"),
      ],
    );
  });
}
