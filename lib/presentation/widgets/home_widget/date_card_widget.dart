import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart'; // AppColors importi

class DataCard extends StatelessWidget {
  final String date;

  const DataCard({
    super.key,
    this.date = '29 September 2023', // Default qiymat
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mintLight), // Nozik chegara
        boxShadow: [
          BoxShadow(
            color: AppColors.forestDark.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.start, // Kontentga qarab o'lcham oladi
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            color: AppColors.primary, // Emerald Green
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            date,
            style: const TextStyle(
              color: AppColors.forestDark,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
