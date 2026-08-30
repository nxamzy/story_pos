import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

/// Kategoriya chiplari. Ro'yxat va tanlangan qiymat tashqaridan (BLoC
/// state'idan) beriladi — shu sababli haqiqiy mahsulot kategoriyalari bilan
/// har doim mos keladi.
class CategoryList extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onCategorySelected;

  const CategoryList({
    super.key,
    required this.categories,
    required this.selected,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selected == category;
          return GestureDetector(
            onTap: () => onCategorySelected(category),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.mintLight,
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.forestDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
