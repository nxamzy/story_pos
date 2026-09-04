import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';

class MenuGrid extends StatelessWidget {
  const MenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Har bir qatorning yo'li bor, shuning uchun "yo'l yo'q" holati
    // uchun 'Tez orada' tarmog'i ham kerak emas edi — u hech qachon
    // ishga tushmasdi. Yozuvlar (record) tipi buni endi imkonsiz qiladi.
    final menuItems = <({String title, IconData icon, String route})>[
      (
        title: 'Xaridlar',
        icon: Icons.shopping_bag_outlined,
        route: PlatformRoutes.purchasesPage.route,
      ),
      (
        title: 'Xarajatlar',
        icon: Icons.payments_outlined,
        route: PlatformRoutes.expensesPage.route,
      ),
      (
        title: 'Mijozlar',
        icon: Icons.people_outline,
        route: PlatformRoutes.customersPage.route,
      ),
      (
        // Ilgari "Hisob-fakturalar" deb turgan, lekin hech qanday hujjat
        // tizimi yo'q edi. Do'konga kerak bo'ladigan narsa — eski chekni
        // topish, shuning uchun savdolar tarixi.
        title: 'Savdolar tarixi',
        icon: Icons.receipt_long_outlined,
        route: PlatformRoutes.salesHistoryPage.route,
      ),
      (
        // Xodimlar ro'yxati ochiladi. Ilgari bu yerdan `/employee` yo'liga
        // (bitta xodim profiliga) hech qanday xodimsiz o'tilardi va ekran
        // soxta "Administrator" profilini ko'rsatardi.
        title: 'Xodimlar',
        icon: Icons.admin_panel_settings_outlined,
        route: PlatformRoutes.showAllProfile.route,
      ),
      (
        title: 'Hisobotlar',
        icon: Icons.pie_chart_outline,
        route: PlatformRoutes.repostsPage.route,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];

        return _MenuItemCard(
          title: item.title,
          icon: item.icon,
          onTap: () => context.push(item.route),
        );
      },
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _MenuItemCard({required this.title, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.mintLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.forestDark.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.forestDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
