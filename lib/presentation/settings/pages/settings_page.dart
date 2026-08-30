import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/core/widgets/confirm_dialog.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_bloc.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_event.dart';
import 'package:ocam_pos/presentation/settings/widgets/settings_item.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _comingSoon(BuildContext context) =>
      AppSnackBar.info(context, "Tez orada qo'shiladi");

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
          'Sozlamalar',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: AppColors.mintLight),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Do'kon ma'lumoti"),
            SettingsItem(
              title: "Do'kon nomi",
              icon: Icons.store_outlined,
              onTap: () => _comingSoon(context),
            ),
            SettingsItem(
              title: "Aloqa raqami",
              icon: Icons.phone_in_talk_outlined,
              onTap: () => _comingSoon(context),
            ),
            SettingsItem(
              title: "STIR",
              icon: Icons.assignment_outlined,
              onTap: () => _comingSoon(context),
            ),
            SettingsItem(
              title: "Manzil",
              icon: Icons.location_on_outlined,
              onTap: () => _comingSoon(context),
            ),

            _buildSectionTitle("Kassa sozlamalari"),
            SettingsItem(
              title: "Valyuta",
              icon: Icons.payments_outlined,
              onTap: () => _comingSoon(context),
            ),

            _buildSectionTitle("Qurilma sozlamalari"),
            SettingsItem(
              title: "Printer",
              icon: Icons.print_outlined,
              onTap: () => _comingSoon(context),
            ),
            SettingsItem(
              title: "Shtrix-kod skaneri",
              icon: Icons.qr_code_scanner_outlined,
              onTap: () => _comingSoon(context),
            ),

            _buildSectionTitle("Umumiy sozlamalar"),
            SettingsItem(
              title: "Bildirishnomalar",
              icon: Icons.notifications_none_outlined,
              onTap: () => _comingSoon(context),
            ),
            SettingsItem(
              title: "Vaqt formati",
              icon: Icons.access_time,
              onTap: () => _comingSoon(context),
            ),

            const SizedBox(height: 20),
            _buildLogoutButton(context),
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

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        onTap: () async {
          final confirmed = await showConfirmDialog(
            context,
            title: "Chiqish",
            message: "Hisobingizdan chiqishni istaysizmi?",
            confirmLabel: "Ha, chiqish",
          );
          if (confirmed && context.mounted) {
            context.read<AuthBloc>().add(const SignOutRequested());
          }
        },
        leading: const Icon(Icons.logout, color: AppColors.error),
        title: const Text(
          "Chiqish",
          style: TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
