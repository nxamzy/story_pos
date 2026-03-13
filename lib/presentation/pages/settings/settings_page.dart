import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/presentation/widgets/settings_widget/settings_item.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(height: 1, color: AppColors.mintLight),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Business Info"),
            SettingsItem(
              title: "Store Name",
              icon: Icons.store_outlined,
              onTap: () {},
            ),
            SettingsItem(
              title: "Hotline",
              icon: Icons.phone_in_talk_outlined,
              onTap: () {},
            ),
            SettingsItem(
              title: "VAT Identification Number",
              icon: Icons.assignment_outlined,
              onTap: () {},
            ),
            SettingsItem(
              title: "Address",
              icon: Icons.location_on_outlined,
              onTap: () {},
            ),

            _buildSectionTitle("Cash Drawer Settings"),
            SettingsItem(
              title: "Currency",
              icon: Icons.payments_outlined,
              onTap: () {},
            ),

            _buildSectionTitle("Hardware Settings"),
            SettingsItem(
              title: "Printer",
              icon: Icons.print_outlined,
              onTap: () {},
            ),
            SettingsItem(
              title: "Barcode Scanner",
              icon: Icons.qr_code_scanner_outlined,
              onTap: () {},
            ),

            _buildSectionTitle("General Settings"),
            SettingsItem(
              title: "Notifications",
              icon: Icons.notifications_none_outlined,
              onTap: () {},
            ),
            SettingsItem(
              title: "Time Format",
              icon: Icons.access_time,
              onTap: () {},
            ),

            const SizedBox(height: 20),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.sage,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
      ),
      child: ListTile(
        onTap: () {
          /* Logout mantiqi */
        },
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text(
          "Logout",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
