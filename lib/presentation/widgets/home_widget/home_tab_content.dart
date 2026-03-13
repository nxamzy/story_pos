import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/presentation/widgets/home_widget/body_widget.dart';
import 'package:ocam_pos/presentation/widgets/home_widget/header_widget.dart';

class HomeTabContent extends StatelessWidget {
  const HomeTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // White
      body: Stack(
        children: [
          // Yuqori yashil fon (Header orqasidagi fon)
          Container(
            height: 300,
            decoration: const BoxDecoration(
              color: AppColors.primary, // emeraldBase
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Header(), // Sening Header vidjeting
                Expanded(child: const Body()), // Sening Body vidjeting
              ],
            ),
          ),
        ],
      ),
    );
  }
}
