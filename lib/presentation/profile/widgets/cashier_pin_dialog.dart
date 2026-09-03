import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/theme/app_text_styles.dart';
import 'package:ocam_pos/core/utils/pin_hasher.dart';

/// Kassirning PIN kodini so'raydi. Kiritilgan PIN qaytariladi, bekor
/// qilinsa `null`.
///
/// PIN faqat "kim kassada turibdi"ni tasdiqlash uchun — u Firebase
/// hisobining paroli emas (`PinHasher` izohiga qarang).
Future<String?> showCashierPinDialog(
  BuildContext context, {
  required String employeeName,
}) async {
  final controller = TextEditingController();

  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text("$employeeName — PIN kod", style: AppTextStyles.title),
      content: TextField(
        controller: controller,
        autofocus: true,
        obscureText: true,
        keyboardType: TextInputType.number,
        maxLength: PinHasher.pinLength,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, letterSpacing: 8),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          hintText: '••••',
          counterText: '',
        ),
        onSubmitted: (value) => Navigator.of(ctx).pop(value),
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
          onPressed: () => Navigator.of(ctx).pop(controller.text),
          child: const Text(
            "Tasdiqlash",
            style: TextStyle(
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
