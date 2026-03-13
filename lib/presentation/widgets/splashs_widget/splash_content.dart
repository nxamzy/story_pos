import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class SplashContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final int activeIndex;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final String leftButtonText;

  const SplashContent({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.activeIndex,
    required this.onSkip,
    required this.onNext,
    this.leftButtonText = "Skip",
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // Yuqori egri qism
          SizedBox(
            height: size.height * 0.61,
            child: Stack(
              children: [
                ClipPath(
                  clipper: BottomCurveClipper(),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(color: AppColors.primary),
                  ),
                ),
                Center(
                  child: Icon(icon, size: 180, color: AppColors.mintLight),
                ),
              ],
            ),
          ),

          // Matnlar qismi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.forestDark,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.forestMedium,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Pastki boshqaruv tugmalari
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    leftButtonText,
                    style: const TextStyle(
                      color: AppColors.forestLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Indikator nuqtalar
                Row(
                  children: List.generate(
                    3,
                    (index) => _buildDot(index == activeIndex),
                  ),
                ),

                ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                    elevation: 0,
                  ),
                  child: const Icon(Icons.chevron_right, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.mintMedium,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);
    var firstControlPoint = Offset(size.width / 2, size.height + 60);
    var firstEndPoint = Offset(size.width, size.height - 80);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
