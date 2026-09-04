import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore'dan kelgan qiymatlarni xavfsiz o'girish uchun yordamchilar.
///
/// Firestore bir xil maydonni goh `Timestamp`, goh `String`, goh `null`
/// qilib qaytarishi mumkin (masalan `serverTimestamp()` yozilgan zahoti
/// lokal snapshot'da `null` bo'ladi) — shu sababli hamma joyda shular ishlatiladi.
class ModelUtils {
  const ModelUtils._();

  static DateTime? dateOrNull(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static DateTime date(dynamic value, {DateTime? fallback}) =>
      dateOrNull(value) ?? fallback ?? DateTime.now();

  static double toDouble(dynamic value, [double fallback = 0]) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll(',', '.')) ?? fallback;
  }

  static int toInt(dynamic value, [int fallback = 0]) {
    if (value == null) return fallback;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  static bool toBool(dynamic value, [bool fallback = false]) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value.toString().toLowerCase();
    if (text == 'true') return true;
    if (text == 'false') return false;
    return fallback;
  }

  static String toStr(dynamic value, [String fallback = '']) =>
      value?.toString() ?? fallback;
}
