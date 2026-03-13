import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class DeleteConfirmationCheckbox extends StatelessWidget {
  final bool isChecked;
  final VoidCallback onTap;

  const DeleteConfirmationCheckbox({
    super.key,
    required this.isChecked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isChecked ? AppColors.primary : AppColors.mintMedium,
                  width: 2,
                ),
                color: isChecked ? AppColors.primary : Colors.transparent,
              ),
              child: isChecked
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            const Text(
              "Yes, I want to delete this supplier",
              style: TextStyle(
                color: AppColors.forestMedium,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
