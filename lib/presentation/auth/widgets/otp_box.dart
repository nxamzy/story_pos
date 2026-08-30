import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class CustomOTPBox extends StatelessWidget {
  final bool isFirst;
  final bool isLast;

  const CustomOTPBox({super.key, required this.isFirst, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mintLight),
      ),
      child: TextField(
        autofocus: isFirst,
        onChanged: (value) {
          if (value.length == 1 && !isLast) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && !isFirst) {
            FocusScope.of(context).previousFocus();
          }
        },
        showCursor: true,
        cursorColor: AppColors.primary,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.forestDark,
        ),
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
      ),
    );
  }
}
