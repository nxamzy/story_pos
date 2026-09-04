import 'package:ocam_pos/core/utils/receipt_paper.dart';

/// Ilova bo'ylab ishlatiladigan sozlamalar.
///
/// Bu yerdagi o'zgaruvchan (`static`, `const` emas) qiymatlar do'kon
/// profilidan o'qiladi va `main.dart`dagi `AppSettingsScope` tomonidan
/// o'rnatiladi. Ular global, chunki formatlash va chek chiqarish widget
/// daraxtidan tashqarida ham ishlatiladi (PDF chek, BLoC xabarlari) —
/// `InheritedWidget` u yerlarga yetib bormaydi.
class AppConfig {
  const AppConfig._();

  /// Standart pul birligi — do'kon sozlamasida boshqasi tanlanmagan bo'lsa.
  static const String defaultCurrency = 'UZS';

  /// Mahsulot kam qolgan deb hisoblanadigan standart chegara.
  static const int defaultLowStockThreshold = 5;

  /// Joriy pul birligi. Sozlamalar -> "Valyuta" orqali o'zgartiriladi.
  static String currency = defaultCurrency;

  /// Chek qog'ozi formati. Sozlamalar -> "Printer".
  static ReceiptPaper receiptPaper = ReceiptPaper.roll80;

  /// Shtrix-kod skanerlangach qurilma tebransinmi.
  /// Sozlamalar -> "Shtrix-kod skaneri".
  static bool scannerHaptics = true;

  /// "Kam qoldi" ogohlantirishi chiqadigan chegara.
  /// Sozlamalar -> "Bildirishnomalar".
  static int lowStockThreshold = defaultLowStockThreshold;

  /// Vaqt 24 soatlik ko'rsatilsinmi (aks holda 12 soatlik, AM/PM bilan).
  /// Sozlamalar -> "Vaqt formati".
  static bool use24HourFormat = true;

  /// Savdo ustiga qo'shiladigan soliq foizi (0 = soliqsiz).
  static const double taxRate = 0.0;

  /// Kelajakdagi REST backend manzili.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
}
