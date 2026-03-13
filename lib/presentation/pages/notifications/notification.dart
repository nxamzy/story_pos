import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/presentation/widgets/notification_widget/notification_card.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.mintLight, height: 1.0),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        physics: const BouncingScrollPhysics(),
        children: [
          const Text(
            'Stay up to date',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.forestDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Get notified when products are about to runs out of stock',
            style: TextStyle(fontSize: 14, color: AppColors.sage),
          ),
          const SizedBox(height: 32),

          const Text(
            'New messages',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),

          const NotificationCard(
            title: 'Inventory Alert',
            subtitle: 'Today - 3:00AM',
            message: 'You have only 5 pieces in stock for Redbull!',
            isHighlighted: true,
            icon: Icons.warning_amber_rounded,
          ),

          const SizedBox(height: 32),

          const Text(
            'Other messages',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.forestDark,
            ),
          ),
          const SizedBox(height: 12),

          const NotificationCard(
            title: 'Receipt #001',
            subtitle: '29/09/2023 - 12:00AM',
            message: 'Digital receipt sent out successfully to customer.',
            icon: Icons.receipt_long_rounded,
          ),
          const NotificationCard(
            title: 'Expiration Alert',
            subtitle: '20/09/2023 - 3:00AM',
            message: "'Milk' Expiration date is coming soon.",
            icon: Icons.hourglass_bottom_rounded,
          ),
        ],
      ),
    );
  }
}
