import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class DataCard extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime selectedDate)? onDateSelected;

  const DataCard({super.key, this.initialDate, this.onDateSelected});

  @override
  State<DataCard> createState() => _DataCardState();
}

class _DataCardState extends State<DataCard> {
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    // Agar tashqaridan sana kelmasa, bugungi sanani oladi
    _currentDate = widget.initialDate ?? DateTime.now();
  }

  // --- 📅 KALENDARNI OCHISH FUNKSIYASI ---
  Future<void> _selectDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _currentDate,
        firstDate: DateTime(2020), // Eng boshlang'ich sana
        lastDate: DateTime(2030), // Eng oxirgi sana
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary, // Emerald Green
                onPrimary: AppColors.white,
                onSurface: AppColors.forestDark,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null && picked != _currentDate) {
        setState(() {
          _currentDate = picked;
        });

        // Tanlangan sanani tashqariga (sahifaga) yuboramiz
        if (widget.onDateSelected != null) {
          widget.onDateSelected!(picked);
        }
      }
    } catch (e) {
      debugPrint("Sana tanlashda xato: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sanani chiroyli formatga keltirish: "29 September 2023"
    final String formattedDate = DateFormat(
      'dd MMMM yyyy',
    ).format(_currentDate);

    return InkWell(
      onTap: () => _selectDate(context), // Bosganda kalendar ochiladi
      borderRadius: BorderRadius.circular(16),
      child: Container(
        // Uzun bo'lishi uchun kenglikni cheklamaymiz yoki double.infinity beramiz
        width: double.infinity,
        padding: const EdgeInsets.all(6), // Paddingni normallashtirdik
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.mintLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.forestDark.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          // mainAxisSize: MainAxisSize.min olib tashlandi, endi Row butun kenglikni egallaydi
          children: [
            // 1. Chap tomondagi Icon (Leading kabi)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 20),

            // 2. Markazdagi Matnlar (Title va Subtitle kabi)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Tanlangan sana",
                    style: TextStyle(
                      color: AppColors.sage.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: AppColors.forestDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // 3. O'ng tomondagi o'q (Trailing kabi)
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.sage,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
