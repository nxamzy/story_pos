import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/theme/app_text_styles.dart';

/// Bitta matn maydonini so'raydigan oddiy oyna.
///
/// Saqlansa kiritilgan matn, bekor qilinsa `null` qaytadi.
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  String initialValue = '',
  String? hint,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  String saveLabel = "Saqlash",
}) async {
  final controller = TextEditingController(text: initialValue);

  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: AppTextStyles.title),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textInputAction: maxLines > 1
            ? TextInputAction.newline
            : TextInputAction.done,
        decoration: InputDecoration(hintText: hint),
        onSubmitted: maxLines > 1
            ? null
            : (value) => Navigator.of(ctx).pop(value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text(
            "Bekor qilish",
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
          child: Text(
            saveLabel,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  controller.dispose();
  return result;
}
