import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/presentation/onboarding/widgets/splash_content.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';

class FirstSplashPage extends StatefulWidget {
  const FirstSplashPage({super.key});

  @override
  State<FirstSplashPage> createState() => _FirstSplashPageState();
}

class _FirstSplashPageState extends State<FirstSplashPage> {
  Timer? _autoAdvanceTimer;

  /// Foydalanuvchi qo'lda "Keyingi"/"O'tkazib yuborish"ni bosgan bo'lsa,
  /// avtomatik o'tish keyinroq yana bir marta shu sahifani navigatsiya
  /// stackiga qo'shib yubormasligi kerak — `context.push` eski sahifani
  /// `dispose` qilmaydi, shu sababli faqat `mounted` tekshiruvi yetarli emas.
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
    context.push(PlatformRoutes.secondsPage.route);
  }

  void _goSkip() {
    _navigated = true;
    _autoAdvanceTimer?.cancel();
    context.push(PlatformRoutes.homePage.route);
  }

  @override
  Widget build(BuildContext context) {
    return SplashContent(
      icon: Icons.bolt,
      title: "Biznesingizni kuchaytiring",
      description:
          "Tendensiyalarni kuzating, asosli qarorlar qabul qiling va biznesingizni rivojlantiring.",
      activeIndex: 0,
      onSkip: _goSkip,
      onNext: _goNext,
    );
  }
}
