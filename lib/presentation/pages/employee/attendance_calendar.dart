import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class AttendanceCalendar extends StatelessWidget {
  const AttendanceCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Attendance Calendar",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Icon(Icons.calendar_month, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 16),
          // Bu yerda senga 'table_calendar' paketi kerak bo'ladi,
          // hozircha oddiy mock (imitatsiya) qilib turamiz:
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              7,
              (index) => _buildDateIcon(index + 10, index == 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateIcon(int day, bool isSelected) {
    return Column(
      children: [
        Text("Mo", style: TextStyle(fontSize: 10, color: AppColors.sage)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "$day",
            style: TextStyle(color: isSelected ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }
}
