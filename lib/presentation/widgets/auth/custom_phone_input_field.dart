import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class CustomPhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const CustomPhoneInputField({
    super.key,
    required this.controller,
    this.hint = "Phone Number",
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.mintLight),
          ),
          child: Row(
            children: [
              Image.network(
                "https://flagcdn.com/w20/eg.png",
                width: 24,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.flag, size: 20, color: AppColors.sage),
              ),
              const SizedBox(width: 8),
              const Text(
                "+20",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestDark,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: AppColors.sage,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            style: const TextStyle(
              color: AppColors.forestDark,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.sage),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
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
        ),
      ],
    );
  }
}
