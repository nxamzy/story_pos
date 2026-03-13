import 'package:flutter/material.dart';
import 'package:ocam_pos/presentation/widgets/onboard_widget/onboarding_components.dart';
import 'package:ocam_pos/presentation/widgets/onboard_widget/onboarding_page_item.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // 1. Ma'lumotlar ro'yxatini shu yerga (yoki alohida faylga) joylashtiramiz
  final List<Map<String, dynamic>> _pages = [
    {
      "title": "Empower Your Business",
      "desc":
          "Discover trends, make informed decisions, and watch your business grow with real-time analytics.",
      "icon": Icons.bolt,
    },
    {
      "title": "Track Performance",
      "desc":
          "Monitor your progress with detailed reports tailored for your specific needs.",
      "icon": Icons.bar_chart_rounded,
    },
    {
      "title": "Stay Connected",
      "desc":
          "Get instant notifications and stay in touch with your team anytime, anywhere.",
      "icon": Icons.hub_rounded,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ASOSIY SAHIFALAR
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                // Ma'lumotni yangi ajratilgan vidjetga uzatamiz
                return OnboardingPageItem(data: _pages[index], size: size);
              },
            ),
          ),

          // PASTI (TUGMALAR VA NUQTALAR)
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // SKIP TUGMASI
                TextButton(
                  onPressed: () {
                    _pageController.animateToPage(
                      _pages.length - 1,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.fastOutSlowIn,
                    );
                  },
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _currentIndex == _pages.length - 1 ? 0.0 : 1.0,
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        color: Color(0xFFE65100),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // NUQTALAR (Indicator) - Alohida fayldan kelyapti
                Row(
                  children: List.generate(
                    _pages.length,
                    (index) => OnboardingDot(isActive: _currentIndex == index),
                  ),
                ),

                // NEXT TUGMASI
                ElevatedButton(
                  onPressed: () {
                    if (_currentIndex < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutQuart,
                      );
                    } else {
                      print("Homega o'tish");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE65100),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      _currentIndex == _pages.length - 1
                          ? Icons.check
                          : Icons.chevron_right,
                      key: ValueKey<int>(_currentIndex),
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
