import 'package:flutter/material.dart';

/// Ilovaning yagona rang palitrasi.
///
/// UI'da to'g'ridan-to'g'ri `Color(0xFF...)` yozilmaydi — hammasi shu yerdan.
class AppColors {
  const AppColors._();

  // --- Asosiy yashil palitra ---
  static const Color mintLight = Color(0xFFD8F3DC);
  static const Color mintMedium = Color(0xFFB7E4C7);
  static const Color sage = Color(0xFF95D5B2);
  static const Color emeraldLight = Color(0xFF74C69D);
  static const Color emeraldMedium = Color(0xFF52B788);
  static const Color emeraldBase = Color(0xFF40916C);
  static const Color forestLight = Color(0xFF2D6A4F);
  static const Color forestMedium = Color(0xFF1B4332);
  static const Color forestDark = Color(0xFF081C15);

  // --- Neytral ranglar ---
  static const Color white = Colors.white;
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F6F7);
  static const Color grey200 = Color(0xFFDFE2E6);
  static const Color grey300 = Color.fromARGB(255, 103, 103, 103);
  static const Color grey400 = Color(0xFF8E9AAB);

  // --- Semantik ranglar ---
  static const Color primary = emeraldBase;
  static const Color secondary = forestLight;
  static const Color background = white;
  static const Color scaffold = grey50;
  static const Color surface = mintLight;
  static const Color card = white;
  static const Color border = grey200;
  static const Color divider = Color(0xFFEDEFF2);

  static const Color textPrimary = Color(0xFF15294B);
  static const Color textSecondary = Color(0xFF243757);
  static const Color textMuted = grey400;
  static const Color textOnPrimary = white;

  static const Color success = emeraldMedium;
  static const Color error = Color(0xFFE23D3D);
  static const Color warning = Color(0xFFF5A524);
  static const Color info = Color(0xFF3D8BE2);

  /// Kartochkalar uchun yumshoq soya (Figma: Main Shadow).
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      blurRadius: 15,
      offset: const Offset(0, 0),
    ),
  ];
}
