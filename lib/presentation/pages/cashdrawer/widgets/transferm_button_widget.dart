import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart'; // AppColors importi
import 'package:ocam_pos/presentation/pages/cashdrawer/widgets/showConfirmTransfer_widget.dart';

class TransfermButtonWidget extends StatefulWidget {
  const TransfermButtonWidget({super.key});

  @override
  State<TransfermButtonWidget> createState() => _TransfermButtonWidgetState();
}

class _TransfermButtonWidgetState extends State<TransfermButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20), // Standart padding
      child: ElevatedButton(
        onPressed: () => showConfirmTransfer(context),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.primary, // Emerald Green - Muvaffaqiyat rangi
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(
            double.infinity,
            56,
          ), // Biroz balandroq va qulayroq
        ),
        child: const Text(
          "Transfer Balance",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
