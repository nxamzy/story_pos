import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class AttendanceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final String status;
  final Color statusColor;

  const AttendanceTile({
    super.key,
    required this.icon,
    required this.title,
    required this.time,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mintLight),
      ),
      child: Row(
        children: [
          _buildIcon(),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.forestDark,
              ),
            ),
          ),
          _buildTimeInfo(),
        ],
      ),
    );
  }

  Widget _buildIcon() => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.white,
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.mintLight),
    ),
    child: Icon(icon, color: AppColors.sage, size: 20),
  );

  Widget _buildTimeInfo() => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        time,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.forestDark,
        ),
      ),
      Text(
        status,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
