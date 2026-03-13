import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

// Modalni chaqirish funksiyasi
void showSupplierSuccessSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const SuccessSupplierSheet(),
  );
}

class SuccessSupplierSheet extends StatelessWidget {
  const SuccessSupplierSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle (tepadagi chiziqcha)
          Container(
            width: 45,
            height: 5,
            margin: const EdgeInsets.only(bottom: 25),
            decoration: BoxDecoration(
              color: AppColors.mintMedium,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // 1. Tasdiq rasmi yoki Ikonka
          // Bu yerda yashil muvaffaqiyat ikonkasini kattaroq va chiroyli qilamiz
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.mintLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 80,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            "Supplier Added!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.forestDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "New supplier has been created successfully",
            style: TextStyle(color: AppColors.sage, fontSize: 14),
          ),
          const SizedBox(height: 30),

          // 2. YETKAZIB BERUVCHI KARTOCHKASI (Yashil uslubda)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.mintLight),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.mintLight,
                    child: Icon(Icons.business, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "New Supplier Created",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.forestDark,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Ready for procurement",
                        style: TextStyle(fontSize: 13, color: AppColors.sage),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 3. ASOSIY TUGMA (Yashil va baquvvat)
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Modalni yopish
                Navigator.pop(context); // Add sahifasidan chiqish
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Continue to List",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
