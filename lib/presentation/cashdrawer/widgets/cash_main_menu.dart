import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/app_config.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';

class CashMainMenuWidget extends StatelessWidget {
  final double balance;

  const CashMainMenuWidget({super.key, required this.balance});

  static PopupMenuItem<String> _menuItem(
    String route,
    IconData icon,
    String label,
  ) {
    return PopupMenuItem<String>(
      value: route,
      child: Row(
        children: [
          Icon(icon, color: AppColors.forestDark, size: 20),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.forestDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      height: 250,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 45),
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Kassa',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Ilgari bu belgi faqat "Tez orada" xabarini chiqarardi.
              // Endi kassaga aloqador bo'limlarga tez o'tish menyusi.
              PopupMenuButton<String>(
                icon: const Icon(Icons.menu_outlined, color: AppColors.white),
                offset: const Offset(0, 45),
                color: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (route) => context.push(route),
                itemBuilder: (context) => [
                  _menuItem(
                    PlatformRoutes.transferLogsPage.route,
                    Icons.swap_horiz_rounded,
                    "O'tkazmalar tarixi",
                  ),
                  _menuItem(
                    PlatformRoutes.expensesPage.route,
                    Icons.payments_outlined,
                    "Xarajatlar",
                  ),
                  _menuItem(
                    PlatformRoutes.repostsPage.route,
                    Icons.pie_chart_outline,
                    "Hisobot",
                  ),
                ],
              ),
              const SizedBox(width: 20),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30, right: 30, left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Kassadagi mavjud mablag'",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mintLight,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppFormat.number(balance),
                  style: const TextStyle(
                    fontSize: 42,
                    color: AppColors.primary,
                    letterSpacing: -1,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppConfig.currency,
                  style: const TextStyle(
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
