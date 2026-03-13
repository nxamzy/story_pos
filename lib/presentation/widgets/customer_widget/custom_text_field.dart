import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool hasError;
  final bool showClear;
  final TextInputType keyboardType;
  final int maxLines;

  const CustomInputField({
    super.key,
    required this.label,
    required this.controller,
    this.hasError = false,
    this.showClear = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.sage, fontSize: 14),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: showClear && controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.cancel_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: () => controller.clear(),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? Colors.red : AppColors.mintLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? Colors.red : AppColors.primary,
            width: 1.5,
          ),
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
      ),
    );
  }
}
