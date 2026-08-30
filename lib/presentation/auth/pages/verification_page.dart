import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';
import 'package:ocam_pos/presentation/auth/widgets/otp_box.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildBackButton(context),

              const SizedBox(height: 32),

              const Text(
                "Tasdiqlash kodini kiriting",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "4 xonali kod raqamingizga yuborildi",
                style: TextStyle(fontSize: 15, color: AppColors.sage),
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Text(
                    "Kodni qayta so'rash: ",
                    style: TextStyle(color: AppColors.sage, fontSize: 14),
                  ),
                  Text(
                    "00:56",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  CustomOTPBox(isFirst: true, isLast: false),
                  CustomOTPBox(isFirst: false, isLast: false),
                  CustomOTPBox(isFirst: false, isLast: false),
                  CustomOTPBox(isFirst: false, isLast: true),
                ],
              ),

              const Spacer(),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Kod kelmadimi? ",
                      style: TextStyle(
                        color: AppColors.forestDark,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        "Qayta yuborish",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _buildVerifyButton(context),
              const SizedBox(height: 24),
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

  Widget _buildVerifyButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          context.push(PlatformRoutes.chanegePassword.route);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Tasdiqlash",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
