import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart'; // AppColors importi

class CashMainMenuWidget extends StatefulWidget {
  const CashMainMenuWidget({super.key});

  @override
  State<CashMainMenuWidget> createState() => _CashMainMenuWidgetState();
}

class _CashMainMenuWidgetState extends State<CashMainMenuWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.forestDark, // To'q yashil/qora fon
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      height: 250,
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // --- NAVIGATION ROW ---
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.primary, // Emerald yashil
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Cashdrawer',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.menu_outlined, color: AppColors.white),
              const SizedBox(width: 20),
            ],
          ),

          // --- BALANCE SECTION ---
          Padding(
            padding: const EdgeInsets.only(top: 30, right: 30, left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'المبلغ المتاح فى الصندوق', // Kassadagi mavjud qoldiq
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mintLight, // Yumshoq och yashil
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "2,909.20",
                  style: TextStyle(
                    fontSize: 42,

                    color: AppColors.primary, // Asosiy Emerald yashil
                    letterSpacing: -1,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'جنيه مصري', // Misr funti
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
