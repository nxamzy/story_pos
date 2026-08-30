import 'package:flutter_test/flutter_test.dart';
import 'package:ocam_pos/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('bo\'sh qiymatni rad etadi', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
    });

    test('formatsiz emailni rad etadi', () {
      expect(Validators.email('notanemail'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
    });

    test('to\'g\'ri emailni qabul qiladi', () {
      expect(Validators.email('user@example.com'), isNull);
    });
  });

  group('Validators.password', () {
    test('6 belgidan qisqa parolni rad etadi', () {
      expect(Validators.password('12345'), isNotNull);
    });

    test('6 va undan uzun parolni qabul qiladi', () {
      expect(Validators.password('123456'), isNull);
    });
  });

  group('Validators.phone', () {
    test('juda qisqa raqamni rad etadi', () {
      expect(Validators.phone('12345'), isNotNull);
    });

    test('to\'liq raqamni qabul qiladi', () {
      expect(Validators.phone('+998901234567'), isNull);
    });
  });

  group('Validators.price', () {
    test('manfiy narxni rad etadi', () {
      expect(Validators.price('-5'), isNotNull);
    });

    test('raqam bo\'lmagan qiymatni rad etadi', () {
      expect(Validators.price('abc'), isNotNull);
    });

    test('to\'g\'ri narxni qabul qiladi', () {
      expect(Validators.price('12000'), isNull);
      expect(Validators.price('0'), isNull);
    });
  });

  group('Validators.quantity', () {
    test('butun bo\'lmagan sonni rad etadi', () {
      expect(Validators.quantity('1.5'), isNotNull);
    });

    test('manfiy sonni rad etadi', () {
      expect(Validators.quantity('-1'), isNotNull);
    });

    test('to\'g\'ri miqdorni qabul qiladi', () {
      expect(Validators.quantity('10'), isNull);
    });
  });
}
