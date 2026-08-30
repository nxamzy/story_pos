import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/presentation/onboarding/widgets/splash_content.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';

class SecondSplashPage extends StatefulWidget {
  const SecondSplashPage({super.key});

  @override
  State<SecondSplashPage> createState() => _SecondSplashPageState();
}

class _SecondSplashPageState extends State<SecondSplashPage> {
  Timer? _autoAdvanceTimer;

  /// `context.push` eski sahifani `dispose` qilmaydi, shu sababli
  /// foydalanuvchi qo'lda o'tgandan keyin ham eski taymer ishga tushib,
  /// bir xil sahifani stackka yana qo'shib yubormasligi uchun kerak.
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _autoAdvanceTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_navigated) _goNext();
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  void _goNext() {
    _navigated = true;
    _autoAdvanceTimer?.cancel();
    context.push(PlatformRoutes.thirtPage.route);
  }

  void _goSkip() {
    _navigated = true;
    _autoAdvanceTimer?.cancel();
    context.push(PlatformRoutes.homePage.route);
  }

  @override
  Widget build(BuildContext context) {
    return SplashContent(
      icon: Icons.insights_rounded,
      title: "Har doim qo'l ostida",
      description:
          "Kichik biznes uchun maxsus mobil savdo tizimi bilan kelajakka qadam qo'ying.",
      activeIndex: 1,
      onSkip: _goSkip,
      onNext: _goNext,
    );
  }
}
