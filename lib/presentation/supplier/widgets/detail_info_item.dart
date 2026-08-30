import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class DetailInfoItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const DetailInfoItem({
    super.key,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.sage, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.forestDark,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        if (!isLast) ...[
          const SizedBox(height: 12),
          Divider(color: AppColors.mintLight, thickness: 1),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
