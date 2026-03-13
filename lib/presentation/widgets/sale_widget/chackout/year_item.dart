import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class YearItem extends StatelessWidget {
  final int year;
  final bool isSelected;
  final bool isCurrent;
  final VoidCallback onTap;

  const YearItem({
    super.key,
    required this.year,
    required this.isSelected,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: isCurrent && !isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          "$year",
          style: TextStyle(
            fontSize: 18,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.forestDark,
          ),
        ),
      ),
    );
  }
}
