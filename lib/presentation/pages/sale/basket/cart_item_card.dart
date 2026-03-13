import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 🎯 Bloc buyruqlarini berish uchun
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/data/models/cart_item_model.dart';
import 'package:ocam_pos/data/models/product_model_1.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;

  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mintLight.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          // 🖼 Mahsulot rasmi
          _buildProductImage(),
          const SizedBox(width: 12),

          // 📝 Ismi va narxi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "${item.product.sellPrice.toStringAsFixed(2)} EGP",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 🔢 MIQDORNI BOSHQARISH (+ / -)
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // ➖ AYIRISH TUGMASI
                _buildQtyButton(
                  icon: Icons.remove,
                  color: AppColors.sage,
                  onTap: () {
                    // Bloc-ga kamaytirish buyrug'ini yuboramiz
                    context.read<BillingBloc>().add(
                      UpdateQuantityEvent(item.product.id, item.quantity - 1),
                    );
                  },
                ),

                // 📦 SONI
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "${item.quantity}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                // ➕ QO'SHISH TUGMASI
                _buildQtyButton(
                  icon: Icons.add,
                  color: AppColors.primary,
                  onTap: () {
                    // Bloc-ga ko'paytirish buyrug'ini yuboramiz
                    context.read<BillingBloc>().add(
                      UpdateQuantityEvent(item.product.id, item.quantity + 1),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Yordamchi metodlar:
  Widget _buildQtyButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(icon, size: 18, color: color),
      onPressed: onTap,
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: item.product.imageUrl != null
            ? Image.network(item.product.imageUrl!, fit: BoxFit.cover)
            : const Icon(Icons.image, color: AppColors.sage),
      ),
    );
  }
}
