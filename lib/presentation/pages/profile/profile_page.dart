import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/logic/blocs/auth/auth_bloc.dart';
import 'package:ocam_pos/logic/blocs/auth/auth_event.dart';
import 'package:ocam_pos/presentation/bloc/profile/profile_bloc.dart';
import 'package:ocam_pos/presentation/bloc/profile/profile_event.dart';
import 'package:ocam_pos/presentation/pages/profile/select_profile.dart';
import 'package:ocam_pos/presentation/widgets/profile_widget/profile_info_card.dart';
import 'package:ocam_pos/presentation/widgets/profile_widget/settings_tile.dart';
import 'package:ocam_pos/routes/platform_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<ProfileBloc>().add(LoadUserProfile(user.uid));
    }
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
          'Profile',
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 10),

            const ProfileInfoCard(),

            const SizedBox(height: 16),

            _buildSettingsSection(),
          ],
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
          const SettingsTile(
            icon: Icons.verified_user_outlined,
            title: "Role & Permissions",
          ),
          const SettingsTile(icon: Icons.home_outlined, title: "Home Address"),
          const SettingsTile(icon: Icons.language, title: "Preferred Language"),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              "Support",
              style: TextStyle(
                color: AppColors.sage,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SettingsTile(icon: Icons.help_outline, title: "Help"),
          const SettingsTile(icon: Icons.info_outline, title: "FAQ"),
          SettingsTile(
            icon: Icons.settings_outlined,
            title: "Settings",
            onTap: () =>
                context.pushReplacement(PlatformRoutes.settingsPage.route),
          ),
          SettingsTile(
            icon: Icons.logout,
            title: "Log out",
            isLogout: true,
            onTap: () {
              context.read<AuthBloc>().add(SignOutRequested());
              context.pushReplacement(PlatformRoutes.loginPage.route);
            },
          ),
        ],
      ),
    );
  }
}
