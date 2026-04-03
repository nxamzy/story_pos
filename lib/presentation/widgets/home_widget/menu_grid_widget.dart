import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/routes/platform_routes.dart';

class MenuGrid extends StatelessWidget {
  const MenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Purchases',
        'icon': Icons.shopping_bag_outlined,
        'route': null,
      },
      {'title': 'Expenses', 'icon': Icons.payments_outlined, 'route': null},
      {
        'title': 'Customers',
        'icon': Icons.people_outline,
        'route': PlatformRoutes.customersPage.route,
      },
      {'title': 'Invoices', 'icon': Icons.receipt_long_outlined, 'route': null},
      {
        'title': 'HRM',
        'icon': Icons.admin_panel_settings_outlined,
        'route': PlatformRoutes.employeeHRMPage.route,
      },
      {
        'title': 'Reports',
        'icon': Icons.pie_chart_outline,
        'route': PlatformRoutes.repostsPage.route,
      },
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
          title: item['title'],
          icon: item['icon'],
          onTap: item['route'] != null
              ? () => context.push(item['route'])
              : null,
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
              color: AppColors.forestDark.withOpacity(0.03),
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
                color: AppColors.primary.withOpacity(0.1),
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
