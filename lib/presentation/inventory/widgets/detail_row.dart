import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isArabic;
  final bool isCategory;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.isArabic = false,
    this.isCategory = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.sage,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          if (isCategory)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.mintLight),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.forestDark,
                fontFamily: isArabic ? 'Arial' : null,
              ),
            ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5, color: AppColors.mintLight),
        ],
      ),
    );
  }
}
