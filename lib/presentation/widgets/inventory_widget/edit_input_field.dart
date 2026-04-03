import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class EditInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isBarcode;
  final bool isDropdown;
  final VoidCallback? onTap;
  final int maxLines;

  const EditInputField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.isBarcode = false,
    this.isDropdown = false,
    this.onTap,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mintLight, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.sage,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                isDropdown
                    ? InkWell(
                        onTap: onTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            controller.text,
                            style: const TextStyle(
                              color: AppColors.forestDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    : TextField(
                        controller: controller,
                        keyboardType: keyboardType,
                        maxLines: maxLines,
                        minLines: 1,
                        style: const TextStyle(
                          color: AppColors.forestDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 8 : 0),
            child: _buildSuffixIcon(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuffixIcon() {
    if (isBarcode) {
      return const Icon(
        Icons.qr_code_scanner_rounded,
        color: AppColors.primary,
        size: 24,
      );
    } else if (isDropdown) {
      return const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.mintMedium,
        size: 28,
      );
    } else {
      return GestureDetector(
        onTap: () => controller.clear(),
        child: const Icon(
          Icons.cancel_outlined,
          color: AppColors.mintMedium,
          size: 20,
        ),
      );
    }
  }
}
