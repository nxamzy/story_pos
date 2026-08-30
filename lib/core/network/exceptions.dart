/// Ilova ichida ishlatiladigan xatolik turlari.
///
/// Data qatlami (datasource) faqat shu exception'larni tashlaydi.
/// Repository ularni [Failure] ga aylantiradi, BLoC esa foydalanuvchiga
/// ko'rsatiladigan matnni state orqali beradi.
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => '$runtimeType($code): $message';
}

/// Server / Firestore tomonidan qaytgan xato.
class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

/// Autentifikatsiya bilan bog'liq xato (login, parol, sessiya).
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

/// Foydalanuvchi tizimga kirmagan holatda himoyalangan amalni bajarmoqchi.
class UnauthenticatedException extends AuthException {
  const UnauthenticatedException()
    : super("Tizimga kirmagansiz", code: 'unauthenticated');
}

/// Internet aloqasi yo'q.
class NetworkException extends AppException {
  const NetworkException([super.message = "Internet aloqasi yo'q"])
    : super(code: 'no-internet');
}

/// So'ralgan ma'lumot topilmadi.
class NotFoundException extends AppException {
  const NotFoundException([super.message = "Ma'lumot topilmadi"])
    : super(code: 'not-found');
}

/// Kiritilgan ma'lumot noto'g'ri (validatsiya).
class ValidationException extends AppException {
  const ValidationException(super.message) : super(code: 'validation');
}

/// Lokal xotira (cache) xatosi.
class CacheException extends AppException {
  const CacheException(super.message) : super(code: 'cache');
}
