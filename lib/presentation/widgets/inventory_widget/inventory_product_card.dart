import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class InventoryProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String qty;
  final String imageUrl;
  final VoidCallback onTap;

  const InventoryProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.qty,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mintLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestDark.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
                  width: 55,
                  height: 55,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.inventory_2_rounded,
                    color: AppColors.sage,
                  ),
                ),
              ),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 4),
                    Text(
                      '$price - $qty',
                      style: const TextStyle(
                        color: AppColors.sage,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.mintMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
