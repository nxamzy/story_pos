import 'package:flutter_test/flutter_test.dart';
import 'package:ocam_pos/core/utils/formatters.dart';

void main() {
  group('AppFormat.money', () {
    test('minglik ajratkichlar bilan formatlaydi', () {
      expect(AppFormat.money(12500), '12 500 UZS');
    });

    test('null qiymatni 0 sifatida ko\'rsatadi', () {
      expect(AppFormat.money(null), '0 UZS');
    });
  });

  group('AppFormat.parseAmount', () {
    test('formatlangan matndan raqam ajratadi', () {
      expect(AppFormat.parseAmount('12 500 UZS'), 12500);
    });

    test('bo\'sh matnda 0 qaytaradi', () {
      expect(AppFormat.parseAmount(''), 0);
      expect(AppFormat.parseAmount(null), 0);
    });

    test('vergul bilan yozilgan sonni to\'g\'ri o\'qiydi', () {
      expect(AppFormat.parseAmount('12,5'), 12.5);
    });
  });
}
