import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart'; // AppColors importi

void showConfirmTransfer(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return const _ConfirmTransferSheet();
    },
  );
}

class _ConfirmTransferSheet extends StatefulWidget {
  const _ConfirmTransferSheet();

  @override
  State<_ConfirmTransferSheet> createState() => _ConfirmTransferSheetState();
}

class _ConfirmTransferSheetState extends State<_ConfirmTransferSheet> {
  bool isConfirmed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Handle (Tepadagi chiziqcha)
          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.mintLight,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Transfer Ikonkasi (Doira ichida)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.swap_vert_circle_outlined,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          // 3. Balance matni (RichText bilan Emerald rangda)
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: "TOTAL BALANCE ",
                  style: TextStyle(color: AppColors.forestDark),
                ),
                TextSpan(
                  text: "2,909.20 EGP",
                  style: TextStyle(color: AppColors.primary), // Emerald accent
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. Savol matni
          const Text(
            "Are you sure to transfer amount to\nMoamen Raafat?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.forestLight,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // 5. Custom Checkbox (Tasdiqlash)
          _buildCheckboxTile(),

          const SizedBox(height: 24),

          // 6. Confirm Button
          _buildConfirmButton(context),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile() {
    return InkWell(
      onTap: () => setState(() => isConfirmed = !isConfirmed),
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
                color: isConfirmed ? AppColors.primary : AppColors.sage,
                width: 2,
              ),
              color: isConfirmed ? AppColors.primary : Colors.transparent,
            ),
            child: isConfirmed
                ? const Icon(Icons.check, size: 16, color: AppColors.white)
                : null,
          ),
          const SizedBox(width: 10),
          const Text(
            "Yes, I want to transfer to Moamen Raafat",
            style: TextStyle(fontSize: 13, color: AppColors.sage),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isConfirmed ? () => context.pop() : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.mintLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          "Confirm Transfer",
          style: TextStyle(
            color: isConfirmed ? AppColors.white : AppColors.sage,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
