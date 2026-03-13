import 'package:flutter/material.dart';

class AppColors {
  // Tanlangan Coolors palitrasidagi ranglar:
  static const Color mintLight = Color(
    0xFFD8F3DC,
  ); // Eng och yashil (Background uchun)
  static const Color mintMedium = Color(0xFFB7E4C7); // Yumshoq yashil
  static const Color sage = Color(0xFF95D5B2); // Adafiy yashil
  static const Color emeraldLight = Color(0xFF74C69D); // Elementlar uchun
  static const Color emeraldMedium = Color(0xFF52B788); // O'rta yashil
  static const Color emeraldBase = Color(0xFF40916C); // ASOSIY RANG (Primary)
  static const Color forestLight = Color(
    0xFF2D6A4F,
  ); // To'q yashil (Tugmalar uchun)
  static const Color forestMedium = Color(
    0xFF1B4332,
  ); // Juda to'q (Matnlar uchun)
  static const Color forestDark = Color(
    0xFF081C15,
  ); // Eng to'q (Sarlavhalar uchun)

  // Tizim ranglari (Yashil bilan moslashgan)
  static const Color white = Colors.white;
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey300 = Color.fromARGB(255, 103, 103, 103);

  // Asosiy tugma va sarlavhalar uchun kombinatsiya
  static const Color primary = emeraldBase;
  static const Color secondary = forestLight;
  static const Color background = white;
  static const Color surface = mintLight;
}
