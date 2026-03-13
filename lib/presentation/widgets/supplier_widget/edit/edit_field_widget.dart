import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class EditFieldWidget extends StatelessWidget {
  final String label;
  final String initialValue;
  final bool hasClearIcon;

  const EditFieldWidget({
    super.key,
    required this.label,
    required this.initialValue,
    this.hasClearIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue,
        style: const TextStyle(
          color: AppColors.forestDark,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.sage, fontSize: 13),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: Icon(
            Icons.cancel,
            color: hasClearIcon ? AppColors.primary : AppColors.mintMedium,
            size: 20,
          ),
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
