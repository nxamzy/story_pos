import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class QuickAddInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? suffixIcon;
  final bool showClear;
  final int maxLines;
  final VoidCallback? onSuffixTap;
  final TextInputType? keyboardType; // 🎯 YANGI: Klaviaturani boshqarish uchun

  const QuickAddInputField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.suffixIcon,
    this.showClear = false,
    this.maxLines = 1,
    this.onSuffixTap,
    this.keyboardType, // Konstruktorga qo'shdik
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.mintLight, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.sage),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: maxLines,
                  keyboardType: keyboardType, // 🎯 SHU YERDA ISHLAYDI
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forestDark,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: AppColors.sage.withOpacity(0.5),
                    ),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                ),
              ),
              if (suffixIcon != null)
                GestureDetector(
                  onTap: onSuffixTap,
                  child: Icon(suffixIcon, size: 22, color: AppColors.primary),
                ),
              if (showClear)
                GestureDetector(
                  onTap: () => controller.clear(),
                  child: const Icon(
                    Icons.cancel_outlined,
                    size: 20,
                    color: AppColors.mintMedium,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
