import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

/// Ro'yxatlar ustidagi qidiruv maydoni (mahsulot, mijoz, taminotchi).
class AppSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final VoidCallback? onClear;

  const AppSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
        suffixIcon: (controller?.text.isNotEmpty ?? false)
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: AppColors.textMuted,
                onPressed: () {
                  controller?.clear();
                  onChanged('');
                  onClear?.call();
                },
              )
            : null,
      ),
    );
  }
}
