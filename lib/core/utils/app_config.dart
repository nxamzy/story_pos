/// Ilova bo'ylab ishlatiladigan sozlamalar.
class AppConfig {
  const AppConfig._();

  /// Pul birligi. Boshqa valyutaga o'tish uchun shu bitta qatorni o'zgartiring.
  static const String currency = 'UZS';

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
