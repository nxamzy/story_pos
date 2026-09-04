import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/presentation/more/widgets/hub_card.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';

class POSHubPage extends StatelessWidget {
  const POSHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Ko'proq",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.white,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                context.push(PlatformRoutes.notificationsPage.route),
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(child: _buildGrid(context)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ko'proq imkoniyatlar",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.forestDark,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Kassa, qaytarishlar, xarajatlar va sozlamalar",
            style: TextStyle(color: AppColors.sage, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    // Ilgari to'rtta kartochkaning ikkitasi ("Sodiqlik dasturi" va
    // "Kupon yaratish") faqat "Tez orada" xabarini chiqarardi. Endi
    // hammasi ishlaydigan bo'limga olib boradi va ekranning bo'sh qolgan
    // pastki yarmi ham to'ldirildi.
    //
    // `const` emas: `PlatformRoutes.x.route` — const obyektning maydoni,
    // Dart'da bu kompilyatsiya vaqtidagi doimiy hisoblanmaydi.
    final items = <({String title, IconData icon, String route})>[
      (
        title: "Sodiq mijozlar",
        icon: Icons.star_rounded,
        route: PlatformRoutes.loyalCustomersPage.route,
      ),
      (
        title: "Qaytarishlar",
        icon: Icons.assignment_return_rounded,
        route: PlatformRoutes.refundsPage.route,
      ),
      (
        title: "Kassa",
        icon: Icons.account_balance_wallet_rounded,
        route: PlatformRoutes.cashDrawerPage.route,
      ),
      (
        title: "Xarajatlar",
        icon: Icons.payments_rounded,
        route: PlatformRoutes.expensesPage.route,
      ),
      (
        title: "Xaridlar",
        icon: Icons.local_shipping_rounded,
        route: PlatformRoutes.purchasesPage.route,
      ),
      (
        title: "Sozlamalar",
        icon: Icons.settings_rounded,
        route: PlatformRoutes.settingsPage.route,
      ),
    ];

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return HubCard(
          title: item.title,
          icon: item.icon,
          onTap: () => context.push(item.route),
        );
      },
    );
  }
}
