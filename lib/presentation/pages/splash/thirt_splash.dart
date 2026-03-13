import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/presentation/widgets/splashs_widget/splash_content.dart';
import 'package:ocam_pos/routes/platform_routes.dart';

class ThirtSplashPage extends StatelessWidget {
  const ThirtSplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SplashContent(
      icon: Icons.three_g_mobiledata,
      title: "Inventory Made Easy",
      description:
          "Say goodbye to manual counts and hello to automated efficiency.",
      activeIndex: 2,
      leftButtonText: "Back",
      onSkip: () => Navigator.pop(context),
      onNext: () => context.push(PlatformRoutes.loginPage.route),
    );
  }
}
