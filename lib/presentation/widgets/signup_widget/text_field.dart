import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class AuthTextField extends StatelessWidget {
  // 1. Keraksiz, ichkarida e'lon qilingan controllerlarni O'CHIRDIK 🗑️
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller; // Faqat shu qolishi kerak

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.controller, // Controller endi majburiy bo'lsa yaxshi
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.forestDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller, // UI-dan kelayotgan controllerni ulaymiz
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.sage),
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.mintLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
