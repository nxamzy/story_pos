import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/presentation/onboarding/widgets/splash_content.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';

class ThirtSplashPage extends StatelessWidget {
  const ThirtSplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SplashContent(
      icon: Icons.inventory_2_rounded,
      title: "Omborni oson boshqaring",
      description:
          "Qo'lda sanashga xayr ayting — hammasi avtomatik hisoblanadi.",
      activeIndex: 2,
      leftButtonText: "Orqaga",
      onSkip: () => Navigator.pop(context),
      onNext: () => context.push(PlatformRoutes.loginPage.route),
    );
  }
}
