import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class ScannedProductCard extends StatelessWidget {
  const ScannedProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestDark.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: AppColors.mintLight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Added to cart",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "Undo",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  "https://cdn-icons-png.flaticon.com/512/3127/3127450.png",
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Text(
                  "RedBull Energy 250ml",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.forestDark,
                    fontSize: 16,
                  ),
                ),
              ),
              _buildQtyControl(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyControl() {
    return Row(
      children: [
        _qtyBtn(Icons.remove),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "1",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        _qtyBtn(Icons.add),
      ],
    );
  }

  Widget _qtyBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.mintLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: AppColors.primary),
    );
  }
}
