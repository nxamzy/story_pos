import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class DetailsSectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const DetailsSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mintLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestDark.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestDark,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const Divider(height: 24, color: AppColors.mintLight),
          child,
        ],
      ),
    );
  }
}
