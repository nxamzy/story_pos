import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/presentation/more/widgets/hub_card.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';

class POSHubPage extends StatelessWidget {
  const POSHubPage({super.key});

  void _comingSoon(BuildContext context) =>
      AppSnackBar.info(context, "Tez orada qo'shiladi");

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
            "Sovg'alar, xaridlar va aloqa",
            style: TextStyle(color: AppColors.sage, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      physics: const BouncingScrollPhysics(),
      children: [
        HubCard(
          title: "Sodiqlik dasturi",
          icon: Icons.star_rounded,
          onTap: () => _comingSoon(context),
        ),
        HubCard(
          title: "Qaytarishlar",
          icon: Icons.assignment_return_rounded,
          onTap: () => _comingSoon(context),
        ),
        HubCard(
          title: "Kupon yaratish",
          icon: Icons.confirmation_number_rounded,
          onTap: () => _comingSoon(context),
        ),
        HubCard(
          title: "Kassa",
          icon: Icons.account_balance_wallet_rounded,
          onTap: () => context.push(PlatformRoutes.cashDrawerPage.route),
        ),
      ],
    );
  }
}
