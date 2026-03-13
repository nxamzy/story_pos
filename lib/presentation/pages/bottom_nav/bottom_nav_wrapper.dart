import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:ocam_pos/core/theme/app_colors.dart'; // AppColors importi

class BottomNavWrapper extends StatefulWidget {
  const BottomNavWrapper({super.key});

  @override
  State<BottomNavWrapper> createState() => _BottomNavWrapperState();
}

class _BottomNavWrapperState extends State<BottomNavWrapper> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    // Index 2 - Sale sahifasi (Markazdagi scaner) default ochiladi
    _controller = PersistentTabController(initialIndex: 2);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Sahifalar ro'yxati
  List<Widget> _buildScreens() => [
    const Center(
      child: Text("Home", style: TextStyle(color: AppColors.forestDark)),
    ),
    const Center(
      child: Text("Inventory", style: TextStyle(color: AppColors.forestDark)),
    ),
    const Center(
      child: Text("Sale", style: TextStyle(color: AppColors.forestDark)),
    ),
    const Center(
      child: Text("Supplier", style: TextStyle(color: AppColors.forestDark)),
    ),
    const Center(
      child: Text("More", style: TextStyle(color: AppColors.forestDark)),
    ),
  ];

  // Navigatsiya elementlari - Professional Emerald stilida
  List<PersistentBottomNavBarItem> _navBarsItems() => [
    _buildNavItem(Icons.home_outlined, "Home"),
    _buildNavItem(Icons.inventory_2_outlined, "Inventory"),

    // MARKAZIY TUGMA (Style15 uchun maxsus)
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.qr_code_scanner, color: AppColors.white),
      title: "Sale",
      activeColorPrimary: AppColors.primary, // Markazdagi doira Emerald yashil
      inactiveColorPrimary: AppColors.sage,
      activeColorSecondary: AppColors.white, // Ikonka rangi oq qoladi
    ),

    _buildNavItem(Icons.local_shipping_outlined, "Supplier"),
    _buildNavItem(Icons.grid_view_rounded, "More"),
  ];

  // Nav itemlar uchun yordamchi metod (Kod takrorlanmasligi uchun)
  PersistentBottomNavBarItem _buildNavItem(IconData icon, String title) {
    return PersistentBottomNavBarItem(
      icon: Icon(icon),
      title: title,
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      activeColorPrimary: AppColors.primary,
      inactiveColorPrimary: AppColors.sage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      backgroundColor: AppColors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,

      decoration: NavBarDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        colorBehindNavBar: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.forestDark.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -2),
          ),
        ],
      ),

      // Animatsiya sozlamalari
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings(
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 300),
        ),
      ),
      navBarStyle: NavBarStyle.style15, // Markaziy tugma ko'tarilgan stil
    );
  }
}
