import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/routes/platform_routes.dart';
import 'package:ocam_pos/presentation/widgets/auth/custom_auth_input_field.dart'; // Vidjetni import qilamiz

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  @override
  void dispose() {
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildBackButton(context),
              const SizedBox(height: 32),

              const Text(
                "New Password",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Enter your new password and don’t forget it",
                style: TextStyle(fontSize: 15, color: AppColors.sage),
              ),

              const SizedBox(height: 40),

              // BIZNING YANGI VIDJETIMIZ 🦾
              CustomAuthInputField(
                label: "New Password",
                hint: "Enter new password",
                prefixIcon: Icons.lock_open_rounded,
                controller: _newPassController,
                isPassword: true,
                suffixIcon: Icons.remove_red_eye_outlined,
              ),

              const SizedBox(height: 24),

              CustomAuthInputField(
                label: "Confirm New Password",
                hint: "Confirm new password",
                prefixIcon: Icons.lock_outline,
                controller: _confirmPassController,
                isPassword: true,
                suffixIcon: Icons.remove_red_eye_outlined,
              ),

              const Spacer(),

              // Tasdiqlash tugmasi
              _buildSubmitButton(context),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: () => context.pop(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.mintLight),
        ),
        child: const Icon(
          Icons.chevron_left,
          color: AppColors.primary,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => context.push(PlatformRoutes.loginPage.route),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Confirm new password",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
