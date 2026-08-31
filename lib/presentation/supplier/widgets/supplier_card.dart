import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/data/models/supplier_model.dart';
import 'package:ocam_pos/presentation/supplier/pages/supplier_details_page.dart';

class SupplierCard extends StatelessWidget {
  final SupplierModel supplier;

  const SupplierCard({super.key, required this.supplier});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SupplierDetailsScreen(supplier: supplier),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.mintLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.background,
              ),
              child: supplier.imageUrl.isNotEmpty
                  ? Image.network(
                      supplier.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(
                            Icons.local_shipping_outlined,
                            color: AppColors.sage,
                          ),
                    )
                  : const Icon(
                      Icons.local_shipping_outlined,
                      color: AppColors.sage,
                    ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplier.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.forestDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    supplier.phone,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.sage,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
