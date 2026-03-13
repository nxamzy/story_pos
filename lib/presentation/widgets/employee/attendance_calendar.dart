// lib/presentation/pages/employee/widgets/attendance_calendar.dart
import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class AttendanceCalendar extends StatelessWidget {
  const AttendanceCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'September 2023',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.forestDark,
              ),
            ),
            Icon(Icons.calendar_month_rounded, color: AppColors.primary),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _DayItem(day: '18', weekDay: 'Mo'),
            _DayItem(day: '19', weekDay: 'Tu'),
            _DayItem(day: '20', weekDay: 'We'),
            _DayItem(day: '21', weekDay: 'Th', isSelected: true),
            _DayItem(day: '22', weekDay: 'Fr'),
            _DayItem(day: '23', weekDay: 'Sa'),
            _DayItem(day: '24', weekDay: 'Su'),
          ],
        ),
      ],
    );
  }
}

class _DayItem extends StatelessWidget {
  final String day;
  final String weekDay;
  final bool isSelected;

  const _DayItem({
    required this.day,
    required this.weekDay,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.white : AppColors.forestDark,
            ),
          ),
          Text(
            weekDay,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppColors.white : AppColors.sage,
            ),
          ),
        ],
      ),
    );
  }
}
