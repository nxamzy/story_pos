import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class CheckoutCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const CheckoutCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.mintLight),
        ),
        child: child,
      ),
    );
  }
}
