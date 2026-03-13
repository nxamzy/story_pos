import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/presentation/widgets/splashs_widget/splash_content.dart';
import 'package:ocam_pos/routes/platform_routes.dart';

class SecondSplashPage extends StatefulWidget {
  const SecondSplashPage({super.key});

  @override
  State<SecondSplashPage> createState() => _SecondSplashPageState();
}

class _SecondSplashPageState extends State<SecondSplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.push(PlatformRoutes.thirtPage.route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplashContent(
      icon: Icons.two_k,
      title: "Insights On-the-Go",
      description:
          "Step into the future with our mobile POS system tailored for small businesses.",
      activeIndex: 1,
      onSkip: () => context.push(PlatformRoutes.homePage.route),
      onNext: () => context.push(PlatformRoutes.thirtPage.route),
    );
  }
}
