import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  /// Sozlamaning joriy qiymati (masalan do'kon nomi). Bo'sh bo'lsa
  /// "Kiritilmagan" ko'rsatiladi.
  final String? value;

  const SettingsItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mintLight),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.mintLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.forestDark,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: value == null
            ? null
            : Text(
                value!.isEmpty ? "Kiritilmagan" : value!,
                style: TextStyle(
                  color: value!.isEmpty ? AppColors.mintMedium : AppColors.sage,
                  fontSize: 13,
                ),
              ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.sage,
          size: 20,
        ),
      ),
    );
  }
}
