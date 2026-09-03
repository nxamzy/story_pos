import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Kassir PIN kodini xeshlash.
///
/// PIN hech qachon ochiq matnda saqlanmaydi: Firestore'ga faqat sha256
/// xesh yoziladi. Xodim hujjatining id'si "tuz" (salt) sifatida
/// ishlatiladi — shunda ikki xodimning bir xil PIN'i har xil xesh beradi
/// va bitta xeshni ko'chirib boshqasiga qo'yib bo'lmaydi.
///
/// Eslatma: bu PIN — Firebase hisobining paroli emas. U faqat qaysi kassir
/// ishlayotganini belgilash (savdoni kimga yozish) uchun; ilovaning
/// ma'lumotlarga kirish huquqi baribir do'kon egasining hisobiga bog'liq.
class PinHasher {
  const PinHasher._();

  /// PIN uzunligi — raqamli klaviaturada tez terish uchun 4 xona.
  static const int pinLength = 4;

  static bool isValidPin(String pin) =>
      pin.length == pinLength && int.tryParse(pin) != null;

  static String hash(String pin, {required String salt}) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();

  /// Kiritilgan PIN saqlangan xeshga mos kelishini tekshiradi.
  static bool matches({
    required String pin,
    required String storedHash,
    required String salt,
  }) {
    if (storedHash.isEmpty) return false;
    return hash(pin, salt: salt) == storedHash;
  }
}
