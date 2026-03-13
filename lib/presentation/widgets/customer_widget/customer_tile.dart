import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class CustomerTile extends StatelessWidget {
  final String name;
  final String phone;
  final VoidCallback onTap;

  const CustomerTile({
    super.key,
    required this.name,
    required this.phone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mintLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestDark.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.sage, width: 2),
          ),
          child: const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
          ),
        ),
        title: Text(
          name,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.forestDark,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          phone,
          textAlign: TextAlign.right,
          style: const TextStyle(color: AppColors.grey300),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: AppColors.emeraldBase,
        ),
      ),
    );
  }
}
