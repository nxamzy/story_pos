import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/presentation/pages/inventory/inventory_tab.dart';
import 'package:ocam_pos/presentation/pages/sale/main_sale/sale_screen.dart';
import 'package:ocam_pos/presentation/pages/supplier/supplier_screen.dart';
import 'package:ocam_pos/presentation/widgets/home_widget/home_tab_content.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../more/more.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Widget> _buildScreens() => [
    const HomeTabContent(),
    const InventoryScreen(),
    const SaleScreen(),
    const SupplierScreen(),
    const POSHubPage(),
  ];
  List<PersistentBottomNavBarItem> _navBarsItems() => [
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.home_outlined),
      title: 'Home',
      activeColorPrimary: AppColors.primary,
      inactiveColorPrimary: Colors.grey.shade600,
      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.inventory_2_outlined),
      title: 'Inventory',
      activeColorPrimary: AppColors.primary,
      inactiveColorPrimary: Colors.grey.shade600,
      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.qr_code_scanner, size: 28),
      title: 'Sale',
      activeColorPrimary: AppColors.primary,
      activeColorSecondary: AppColors.white,
      inactiveColorPrimary: AppColors.primary,
      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.local_shipping_outlined),
      title: 'Supplier',
      activeColorPrimary: AppColors.primary,
      inactiveColorPrimary: Colors.grey.shade600,
      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.more_horiz_outlined),
      title: 'More',
      activeColorPrimary: AppColors.primary,
      inactiveColorPrimary: Colors.grey.shade600,
      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
  ];
  @override
  Widget build(BuildContext context) => PersistentTabView(
    context,
    controller: _controller,
    screens: _buildScreens(),
    items: _navBarsItems(),
    handleAndroidBackButtonPress: true,
    resizeToAvoidBottomInset: true,
    stateManagement: true,
    hideNavigationBarWhenKeyboardAppears: true,

    decoration: NavBarDecoration(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      colorBehindNavBar: AppColors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    ),

    navBarStyle: NavBarStyle.style13,
    navBarHeight: 65,
    backgroundColor: AppColors.white,
  );
}
