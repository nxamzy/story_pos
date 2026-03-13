import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/presentation/widgets/more_widget/hub_card.dart';
import 'package:ocam_pos/routes/platform_routes.dart';

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
          "POS Hub",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.white,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
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
            "Explore",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.forestDark,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "perks, purchases, and get in touch",
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
          title: "Loyalty Program",
          icon: Icons.star_rounded,
          onTap: () {},
        ),
        HubCard(
          title: "Returns",
          icon: Icons.assignment_return_rounded,
          onTap: () {},
        ),
        HubCard(
          title: "Create Voucher",
          icon: Icons.confirmation_number_rounded,
          onTap: () {},
        ),
        HubCard(
          title: "Cash Drawer",
          icon: Icons.account_balance_wallet_rounded,
          onTap: () => context.push(PlatformRoutes.cashDrawerPage.route),
        ),
      ],
    );
  }
}
