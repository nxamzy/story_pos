import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final bool isSelected = product["selected"] as bool;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.mintLight : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.mintMedium,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                product["price"] as String,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestDark,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(product["img"] as String, height: 60),
                const SizedBox(height: 10),
                Text(
                  product["name"] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.forestDark,
                  ),
                ),
                if (isSelected) ...[const SizedBox(height: 8), _buildCounter()],
              ],
            ),
          ),
          const Positioned(
            bottom: 10,
            right: 10,
            child: Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: AppColors.sage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _counterBtn(Icons.add),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "1",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.forestDark,
            ),
          ),
        ),
        _counterBtn(Icons.remove),
      ],
    );
  }

  Widget _counterBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }
}
