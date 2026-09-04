import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/core/widgets/text_input_dialog.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_state.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_bloc.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_event.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_bloc.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_event.dart';
import 'package:ocam_pos/presentation/profile/pages/select_profile_page.dart';
import 'package:ocam_pos/presentation/profile/widgets/profile_info_card.dart';
import 'package:ocam_pos/presentation/profile/widgets/settings_tile.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadUserProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
        ),
        title: const Text(
          'Profil',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [_buildSwitchIcon(), const SizedBox(width: 18)],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.mintLight, height: 1.0),
        ),
      ),
      // Manzil saqlangani (yoki xato) haqida xabar shu yerda chiqadi —
      // tahrirlash oynasi Sozlamalarga o'tmasdan shu sahifada ochiladi.
      body: BlocListener<ProfileBloc, ProfileState>(
        listenWhen: (previous, current) =>
            current.actionMessage != null || current.error != null,
        listener: (context, state) {
          if (state.error != null) {
            AppSnackBar.error(context, state.error!);
          } else if (state.actionMessage != null) {
            AppSnackBar.success(context, state.actionMessage!);
          }
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 10),

              const ProfileInfoCard(),

              const SizedBox(height: 16),

              _buildSettingsSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchIcon() {
    return InkWell(
      onTap: () => showConfirmSelect(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: AppColors.mintLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.cameraswitch, color: AppColors.primary),
      ),
    );
  }

  /// Do'kon manzilini tahrirlash — Sozlamalardagi bir xil maydon.
  Future<void> _editAddress(BuildContext context) async {
    final current = context.read<ProfileBloc>().state.user?.address ?? '';

    final value = await showTextInputDialog(
      context,
      title: "Manzil",
      initialValue: current,
      hint: "Shahar, ko'cha, uy",
      maxLines: 2,
    );
    if (value == null || value == current || !context.mounted) return;

    context.read<ProfileBloc>().add(UpdateStoreInfo(address: value));
  }

  Widget _buildSettingsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mintLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsTile(
            icon: Icons.verified_user_outlined,
            title: "Rol va ruxsatlar",
            onTap: () => context.push(PlatformRoutes.rolesPage.route),
          ),
          // Manzil `UserModel.address`da saqlanadi va chekda chop etiladi —
          // Sozlamalardagi bir xil maydonni shu yerdan ham tahrirlash
          // mumkin.
          SettingsTile(
            icon: Icons.home_outlined,
            title: "Manzil",
            onTap: () => _editAddress(context),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              "Yordam",
              style: TextStyle(
                color: AppColors.sage,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SettingsTile(
            icon: Icons.help_outline,
            title: "Yordam markazi",
            onTap: () => context.push(PlatformRoutes.helpPage.route),
          ),
          SettingsTile(
            icon: Icons.info_outline,
            title: "Ko'p so'raladigan savollar",
            onTap: () => context.push(PlatformRoutes.faqPage.route),
          ),
          SettingsTile(
            icon: Icons.settings_outlined,
            title: "Sozlamalar",
            onTap: () => context.push(PlatformRoutes.settingsPage.route),
          ),
          SettingsTile(
            icon: Icons.logout,
            title: "Chiqish",
            isLogout: true,
            // Manzilga o'tish shart emas — AuthBloc holati o'zgarganda
            // GoRouter'ning `redirect`i avtomatik login sahifasiga olib boradi.
            onTap: () => context.read<AuthBloc>().add(const SignOutRequested()),
          ),
        ],
      ),
    );
  }
}
