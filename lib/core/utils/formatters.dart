import 'package:intl/intl.dart';
import 'package:ocam_pos/core/utils/app_config.dart';

/// Pul, sana va raqamlarni bir xil ko'rinishda formatlash.
class AppFormat {
  const AppFormat._();

  static final NumberFormat _number = NumberFormat('#,##0.##', 'en_US');
  static final DateFormat _date = DateFormat('dd.MM.yyyy');
  static final DateFormat _dateLong = DateFormat('d MMMM yyyy');
  static final DateFormat _dateTime = DateFormat('dd.MM.yyyy HH:mm');
  static final DateFormat _time = DateFormat('HH:mm');

  /// 12500 -> "12 500 UZS"
  static String money(num? value) =>
      '${_number.format(value ?? 0).replaceAll(',', ' ')} ${AppConfig.currency}';

  /// 12500 -> "12 500" (valyutasiz)
  static String number(num? value) =>
      _number.format(value ?? 0).replaceAll(',', ' ');

  static String date(DateTime? value) =>
      value == null ? '-' : _date.format(value);

  static String dateLong(DateTime? value) =>
      value == null ? '-' : _dateLong.format(value);

  static String dateTime(DateTime? value) =>
      value == null ? '-' : _dateTime.format(value);

  static String time(DateTime? value) =>
      value == null ? '-' : _time.format(value);

  /// Matndan raqam ajratib oladi ("12 500 UZS" -> 12500).
  static double parseAmount(String? input) {
    if (input == null || input.trim().isEmpty) return 0;
    final cleaned = input.replaceAll(RegExp(r'[^0-9.,-]'), '').replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0;
  }

  /// Tahrirlanadigan matn maydonini oldindan to'ldirish uchun — 5000.0 emas
  /// "5000", faqat kasr qismi bo'lsa saqlanadi (5000.5 -> "5000.5").
  static String editableNumber(num value) => value % 1 == 0
      ? value.toInt().toString()
      : value.toString();
}
