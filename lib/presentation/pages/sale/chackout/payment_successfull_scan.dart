import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 🎯 Bloc qo'shildi
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/data/models/product_model_1.dart';
import 'package:ocam_pos/routes/platform_routes.dart';

// 🎯 Endi bu funksiya summani qabul qiladi
void showSuccessSheet(BuildContext context, double totalAmount) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false, // Foydalanuvchi "New Sale"ni bosishga majbur bo'lsin
    backgroundColor: Colors.transparent,
    builder: (context) => SuccessSheet(totalAmount: totalAmount),
  );
}

class SuccessSheet extends StatelessWidget {
  final double totalAmount; // 💰 Dinamik summa

  const SuccessSheet({super.key, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 45,
            height: 5,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.mintMedium,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // --- Rasm qismi o'zgarishsiz qoladi ---
          SizedBox(
            height: 140,
            child: Image.network(
              "https://cdn3d.iconscout.com/3d/premium/thumb/thumb-up-3d-icon-download-in-png-blend-fbx-gltf-file-formats--like-gesture-hand-finger-ok-hand-gestures-pack-people-icons-4715136.png",
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.check_circle_rounded,
                size: 100,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Sale Completed Successfully",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          // 💸 DINAMIK SUMMA
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.forestDark,
              ),
              children: [
                const TextSpan(text: "TOTAL AMOUNT "),
                TextSpan(
                  text: "${totalAmount.toStringAsFixed(2)} EGP",
                  style: const TextStyle(color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Payment Type : Cash",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.sage,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),

          // --- RECEIPT TUGMASI ---
          InkWell(
            onTap: () => context.push(PlatformRoutes.receiptPage.route),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.mintLight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.receipt_long_outlined, color: AppColors.primary),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Receipt Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.forestDark,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.sage, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 🚀 NEW SALE TUGMASI (ENG MUHIMI)
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: () {
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (userId != null) {
                  // 1. Savatni va holatni tozalash uchun Bloc-ga xabar beramiz
                  context.read<BillingBloc>().add(LoadAllProductsEvent(userId));

                  // 2. Agar Dialog ochilgan bo'lsa, uni yopamiz
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }

                  // BO'LDI! Sahifa o'zgarmaydi, lekin ichidagi ma'lumotlar yangilanadi.
                  // TabBar o'z joyida qoladi!
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                "New Sale",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // ... Send Receipt tugmasi o'zgarishsiz qoladi ...
        ],
      ),
    );
  }
}
