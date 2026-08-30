import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class EditFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool hasClearIcon;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const EditFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    this.hasClearIcon = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          color: AppColors.forestDark,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.sage, fontSize: 13),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: hasClearIcon
              ? IconButton(
                  icon: const Icon(
                    Icons.cancel,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  onPressed: controller.clear,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          filled: true,
          fillColor: AppColors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.mintMedium),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
