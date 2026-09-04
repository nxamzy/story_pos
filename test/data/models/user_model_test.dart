import 'package:flutter_test/flutter_test.dart';
import 'package:ocam_pos/core/utils/app_config.dart';
import 'package:ocam_pos/core/utils/receipt_paper.dart';
import 'package:ocam_pos/data/models/user_model.dart';

void main() {
  group('UserModel qurilma sozlamalari', () {
    test('maydonlar Firestore xaritasiga borib qaytadi', () {
      const user = UserModel(
        uid: 'shop-1',
        email: 'egasi@ocam.uz',
        receiptPaper: ReceiptPaper.roll57,
        scannerHaptics: false,
        lowStockThreshold: 12,
        use24HourFormat: false,
      );

      final restored = UserModel.fromMap(user.toMap(), 'shop-1');

      expect(restored.receiptPaper, ReceiptPaper.roll57);
      expect(restored.scannerHaptics, isFalse);
      expect(restored.lowStockThreshold, 12);
      expect(restored.use24HourFormat, isFalse);
    });

    test("eski hujjatda maydon bo'lmasa standart qiymat olinadi", () {
      // Sozlamalar qo'shilgunga qadar yozilgan profil hujjatlarida bu
      // maydonlar umuman yo'q — ular xatosiz ochilishi kerak.
      final restored = UserModel.fromMap({
        'email': 'egasi@ocam.uz',
        'storeName': 'Ocam',
      }, 'shop-1');

      expect(restored.receiptPaper, ReceiptPaper.roll80);
      expect(restored.scannerHaptics, isTrue);
      expect(restored.lowStockThreshold, AppConfig.defaultLowStockThreshold);
      expect(restored.use24HourFormat, isTrue);
    });

    test("noma'lum qog'oz nomi 80 mm ga tushadi", () {
      expect(ReceiptPaper.fromWire('roll120'), ReceiptPaper.roll80);
      expect(ReceiptPaper.fromWire(null), ReceiptPaper.roll80);
      expect(ReceiptPaper.fromWire('a4'), ReceiptPaper.a4);
    });

    test('copyWith faqat berilgan maydonni almashtiradi', () {
      const user = UserModel(
        uid: 'shop-1',
        email: 'egasi@ocam.uz',
        lowStockThreshold: 7,
      );

      final updated = user.copyWith(receiptPaper: ReceiptPaper.a4);

      expect(updated.receiptPaper, ReceiptPaper.a4);
      expect(updated.lowStockThreshold, 7);
      expect(updated.email, 'egasi@ocam.uz');
    });
  });
}
