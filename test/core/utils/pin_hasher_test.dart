import 'package:flutter_test/flutter_test.dart';
import 'package:ocam_pos/core/utils/pin_hasher.dart';

void main() {
  group('PinHasher', () {
    test('to\'g\'ri PIN xeshga mos keladi', () {
      final hash = PinHasher.hash('1234', salt: 'emp-1');

      expect(
        PinHasher.matches(pin: '1234', storedHash: hash, salt: 'emp-1'),
        isTrue,
      );
    });

    test('noto\'g\'ri PIN rad etiladi', () {
      final hash = PinHasher.hash('1234', salt: 'emp-1');

      expect(
        PinHasher.matches(pin: '4321', storedHash: hash, salt: 'emp-1'),
        isFalse,
      );
    });

    test('bir xil PIN har xil xodimda har xil xesh beradi', () {
      expect(
        PinHasher.hash('1234', salt: 'emp-1'),
        isNot(PinHasher.hash('1234', salt: 'emp-2')),
      );
    });

    test('boshqa xodimning xeshi bilan kirib bo\'lmaydi', () {
      final hash = PinHasher.hash('1234', salt: 'emp-1');

      expect(
        PinHasher.matches(pin: '1234', storedHash: hash, salt: 'emp-2'),
        isFalse,
      );
    });

    test('PIN o\'rnatilmagan bo\'lsa (bo\'sh xesh) hech qanday PIN mos kelmaydi',
        () {
      expect(
        PinHasher.matches(pin: '1234', storedHash: '', salt: 'emp-1'),
        isFalse,
      );
    });

    test('faqat 4 xonali raqam qabul qilinadi', () {
      expect(PinHasher.isValidPin('1234'), isTrue);
      expect(PinHasher.isValidPin('123'), isFalse);
      expect(PinHasher.isValidPin('12345'), isFalse);
      expect(PinHasher.isValidPin('12a4'), isFalse);
      expect(PinHasher.isValidPin(''), isFalse);
    });

    test('PIN ochiq matnda saqlanmaydi', () {
      final hash = PinHasher.hash('1234', salt: 'emp-1');

      expect(hash.contains('1234'), isFalse);
      expect(hash.length, 64); // sha256 — 64 ta hex belgi
    });
  });
}
