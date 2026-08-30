/// Formalar uchun yagona validatsiya qoidalari.
class Validators {
  const Validators._();

  static final RegExp _emailRegExp = RegExp(
    r'^[\w\.\-\+]+@([\w\-]+\.)+[a-zA-Z]{2,}$',
  );

  static String? required(String? value, [String field = 'Maydon']) {
    if (value == null || value.trim().isEmpty) return "$field to'ldirilishi shart";
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return "Email kiriting";
    if (!_emailRegExp.hasMatch(value.trim())) return "Email formati noto'g'ri";
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return "Parol kiriting";
    if (value.length < 6) return "Parol kamida 6 ta belgidan iborat bo'lsin";
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return "Parolni takrorlang";
    if (value != original) return "Parollar mos kelmadi";
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return "Telefon raqam kiriting";
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 9) return "Telefon raqam to'liq emas";
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) return "Narx kiriting";
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) return "Faqat raqam kiriting";
    if (parsed < 0) return "Narx manfiy bo'lishi mumkin emas";
    return null;
  }

  static String? quantity(String? value) {
    if (value == null || value.trim().isEmpty) return "Miqdorni kiriting";
    final parsed = int.tryParse(value);
    if (parsed == null) return "Faqat butun son kiriting";
    if (parsed < 0) return "Miqdor manfiy bo'lishi mumkin emas";
    return null;
  }
}
