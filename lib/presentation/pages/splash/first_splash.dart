import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/presentation/widgets/splashs_widget/splash_content.dart';
import 'package:ocam_pos/routes/platform_routes.dart';

class FirstSplashPage extends StatefulWidget {
  const FirstSplashPage({super.key});

  @override
  State<FirstSplashPage> createState() => _FirstSplashPageState();
}

class _FirstSplashPageState extends State<FirstSplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.push(PlatformRoutes.secondsPage.route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplashContent(
      icon: Icons.bolt,
      title: "Empower Your Business",
      description:
          "Insights On-the-Go. Discover trends, make informed decisions, and watch your business grow",
      activeIndex: 0,
      onSkip: () => context.push(PlatformRoutes.homePage.route),
      onNext: () => context.push(PlatformRoutes.secondsPage.route),
    );
  }
}
