import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class BaseSheetWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showAddBtn;
  final VoidCallback? onAddTap;

  const BaseSheetWrapper({
    super.key,
    required this.title,
    required this.child,
    this.showAddBtn = false,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.mintMedium,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestDark,
                ),
              ),
              if (showAddBtn)
                TextButton.icon(
                  onPressed: onAddTap,
                  icon: const Icon(
                    Icons.add,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  label: const Text(
                    "Add New",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(child: child),
        ],
      ),
    );
  }
}
