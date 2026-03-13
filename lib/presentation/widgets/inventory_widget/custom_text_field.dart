import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator; // 🔥 MANA SHU QATOR QO'SHILDI

  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.suffixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator, // 🔥 VA BU YERGA HAM
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
          // 🎯 DIQQAT: TextField emas, TextFormField ishlatish kerak!
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator, // 🔥 VALIDATORNI SHU YERGA ULAYMIZ
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.mintMedium,
                fontSize: 14,
              ),
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, color: AppColors.mintMedium, size: 22)
                  : null,
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.mintLight,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              // Xato bo'lgandagi chegara
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
