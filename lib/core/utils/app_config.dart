/// Ilova bo'ylab ishlatiladigan sozlamalar.
class AppConfig {
  const AppConfig._();

  /// Standart pul birligi — do'kon sozlamasida boshqasi tanlanmagan bo'lsa.
  static const String defaultCurrency = 'UZS';

  /// Joriy pul birligi. Sozlamalar -> "Valyuta" orqali o'zgartiriladi va
  /// profil yuklanganda `main.dart`da o'rnatiladi (`AppFormat.money` shu
  /// qiymatni o'qiydi).
  static String currency = defaultCurrency;

  /// Savdo ustiga qo'shiladigan soliq foizi (0 = soliqsiz).
  static const double taxRate = 0.0;

  /// Mahsulot kam qolgan deb hisoblanadigan chegara.
  static const int lowStockThreshold = 5;

  /// Kelajakdagi REST backend manzili.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
}
