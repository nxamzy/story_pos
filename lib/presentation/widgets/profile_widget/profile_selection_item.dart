import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class ProfileSelectionItem extends StatelessWidget {
  final int index;
  final String name;
  final String role;
  final bool isSelected;
  final VoidCallback onTap;

  const ProfileSelectionItem({
    super.key,
    required this.index,
    required this.name,
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.mintLight.withOpacity(0.5)
              : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.mintLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.background,
              child: const Icon(Icons.person, color: AppColors.sage),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.forestDark,
                    ),
                  ),
                  Text(
                    role,
                    style: const TextStyle(color: AppColors.sage, fontSize: 13),
                  ),
                ],
              ),
            ),
            // Custom Radio
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.mintMedium,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 6,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
