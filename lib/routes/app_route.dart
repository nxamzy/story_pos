import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/data/models/customer_model.dart';
import 'package:ocam_pos/data/models/employee_model.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'package:ocam_pos/data/models/supplier_model.dart';
import 'package:ocam_pos/logic/blocs/auth/auth_bloc.dart';
import 'package:ocam_pos/logic/blocs/auth/auth_state.dart';

// Sahifalar importi
import 'package:ocam_pos/presentation/pages/cashdrawer/cashdrawer_page.dart';
import 'package:ocam_pos/presentation/pages/customers/add_new_customers.dart';
import 'package:ocam_pos/presentation/pages/customers/customer_details.dart';
import 'package:ocam_pos/presentation/pages/customers/customers.dart';
import 'package:ocam_pos/presentation/pages/employee/employee_hrm.dart';
import 'package:ocam_pos/presentation/pages/home/home.dart';
import 'package:ocam_pos/presentation/pages/inventory/addNewProduct.dart';
import 'package:ocam_pos/presentation/pages/inventory/inventory_tab.dart';
import 'package:ocam_pos/presentation/pages/inventory/product_details_inventory.dart';
import 'package:ocam_pos/presentation/pages/notifications/notification.dart';
import 'package:ocam_pos/presentation/pages/profile/profile_page.dart';
import 'package:ocam_pos/presentation/pages/profile/show_all_profile.dart';
import 'package:ocam_pos/presentation/pages/report/reports.dart';
import 'package:ocam_pos/presentation/pages/sale/basket/basket.dart';
import 'package:ocam_pos/presentation/pages/sale/chackout/checkout.dart';
import 'package:ocam_pos/presentation/pages/sale/main_sale/sale_screen.dart';
import 'package:ocam_pos/presentation/pages/sale/scan/ocr_scan.dart';
import 'package:ocam_pos/presentation/pages/sale/main_sale/receipt/receipt.dart';
import 'package:ocam_pos/presentation/pages/settings/settings_page.dart';
import 'package:ocam_pos/presentation/pages/auth/change_password.dart';
import 'package:ocam_pos/presentation/pages/auth/forgot_password.dart';
import 'package:ocam_pos/presentation/pages/sign_in/sign_in.dart';
import 'package:ocam_pos/presentation/pages/sign_up/sign_up.dart';
import 'package:ocam_pos/presentation/pages/auth/verification.dart';
import 'package:ocam_pos/presentation/pages/splash/first_splash.dart';
import 'package:ocam_pos/presentation/pages/splash/second_splash.dart';
import 'package:ocam_pos/presentation/pages/splash/thirt_splash.dart';
import 'package:ocam_pos/presentation/pages/supplier/addNewSupplier.dart';
import 'package:ocam_pos/presentation/pages/supplier/supplier_screen.dart';
import 'package:ocam_pos/presentation/pages/supplier/supplier_details.dart';
import 'package:ocam_pos/routes/platform_routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    // 🚀 DINAMIK START: User tizimda bo'lsa Home, bo'lmasa Onboarding (FirstSplash)
    initialLocation: FirebaseAuth.instance.currentUser != null
        ? PlatformRoutes.homePage.route
        : PlatformRoutes.firstPage.route,

    // 🔥 TIZIM SERGAKLIGI: FirebaseAuth o'zgarganda Router darhol xabar topadi
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),

    redirect: (BuildContext context, GoRouterState state) {
      final authState = context.read<AuthBloc>().state;
      final String currentLocation = state.matchedLocation;

      // Bu ro'yxatdagilar - faqat kirmaganlar ko'rishi mumkin bo'lgan sahifalar
      final bool isPublicPath =
          currentLocation == PlatformRoutes.firstPage.route ||
          currentLocation == PlatformRoutes.secondsPage.route ||
          currentLocation == PlatformRoutes.thirtPage.route ||
          currentLocation == PlatformRoutes.loginPage.route ||
          currentLocation == PlatformRoutes.signUpPage.route;

      // 1. FOYDALANUVCHI TIZIMDA (Authenticated)
      if (authState is Authenticated) {
        // Faxriy foydalanuvchi "Tanishtiruv" yoki "Login" sahifasida adashib yurgan bo'lsa -> Home-ga!
        if (isPublicPath) {
          return PlatformRoutes.homePage.route;
        }
      }

      // 2. FOYDALANUVCHI TIZIMDAN TASHQARIDA (UnAuthenticated)
      if (authState is UnAuthenticated) {
        // Kirmagan foydalanuvchi "Home" yoki "Profile" kabi yopiq joyga kirmoqchi bo'lsa -> Login-ga!
        // Tanishtiruv (Splashlar) sahifalarida yurgan bo'lsa, xalaqit bermaymiz.
        if (!isPublicPath) {
          return PlatformRoutes.loginPage.route;
        }
      }

      return null; // Qolgan hollarda yo'nalish o'zgarmaydi
    },

    routes: [
      // --- TANISHTIRUV (ONBOARDING) SAHIFALARI ---
      GoRoute(
        path: PlatformRoutes.firstPage.route,
        builder: (context, state) => const FirstSplashPage(),
      ),
      GoRoute(
        path: PlatformRoutes.secondsPage.route,
        builder: (context, state) => const SecondSplashPage(),
      ),
      GoRoute(
        path: PlatformRoutes.thirtPage.route,
        builder: (context, state) => const ThirtSplashPage(),
      ),

      // --- ASOSIY SAHIFA ---
      GoRoute(
        path: PlatformRoutes.homePage.route,
        builder: (context, state) => const HomePage(),
      ),

      // --- AUTHENTICATION ---
      GoRoute(
        path: PlatformRoutes.signUpPage.route,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: PlatformRoutes.loginPage.route,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: PlatformRoutes.forgotPasswordPage.route,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: PlatformRoutes.verification.route,
        builder: (context, state) => const VerificationPage(),
      ),
      GoRoute(
        path: PlatformRoutes.chanegePassword.route,
        builder: (context, state) => const ChangePasswordPage(),
      ),

      // --- PROFILE & SETTINGS ---
      GoRoute(
        path: PlatformRoutes.profilePage.route,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: PlatformRoutes.settingsPage.route,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: PlatformRoutes.showAllProfile.route,
        builder: (context, state) => const ShowAllProfile(),
      ),

      // --- BUSINESS LOGIC ---
      GoRoute(
        path: PlatformRoutes.cashDrawerPage.route,
        builder: (context, state) => const CashDrawerPage(),
      ),
      GoRoute(
        path: PlatformRoutes.notificationsPage.route,
        builder: (context, state) => const NotificationPage(),
      ),
      GoRoute(
        path: PlatformRoutes.customersPage.route,
        builder: (context, state) => const CustomersPage(),
      ),
      GoRoute(
        path: PlatformRoutes.customerdetailsPage.route,
        builder: (context, state) {
          // 1. O'tgan ma'lumotni 'extra'dan olamiz
          // Uni CustomerModel ekanligini tasdiqlaymiz (as CustomerModel)
          final customer = state.extra as CustomerModel;

          // 2. Sahifaga o'sha mijozni berib yuboramiz
          // 'const'ni olib tashlaymiz, chunki ma'lumot dinamik!
          return CustomerDetailsPage(customer: customer);
        },
      ),
      GoRoute(
        path: PlatformRoutes.addNewCustomerPage.route,
        builder: (context, state) => const AddNewCustomerPage(),
      ),
      GoRoute(
        path: PlatformRoutes.employeeHRMPage.route,
        builder: (context, state) => EmployeeHRMScreen(
          employee:
              state.extra as EmployeeModel?, // as EmployeeModel? (so'roq bilan)
        ),
      ),
      GoRoute(
        path: PlatformRoutes.inventoryPage.route,
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: PlatformRoutes.repostsPage.route,
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: PlatformRoutes.addNewProduct.route,
        builder: (context, state) => const AddProductScreen(),
      ),
      GoRoute(
        path: PlatformRoutes.productDetails.route,
        builder: (context, state) {
          // 🎯 Router orqali kelayotgan 'extra' ma'lumotni 'ProductModel'ga aylantiramiz
          final product = state.extra as ProductModel;

          // 🔥 Endi sahifaga o'sha mahsulotni berib yuboramiz
          return ProductDetailsScreen(product: product);
        },
      ),
      GoRoute(
        path: PlatformRoutes.supplierPage.route,
        builder: (context, state) => const SupplierScreen(),
      ),
      GoRoute(
        path: PlatformRoutes.supplierDetailsPage.route,
        builder: (context, state) {
          // 🔥 Map o'rniga SupplierModel deb qabul qilamiz
          final supplier = state.extra as SupplierModel;

          // 🔥 Uni konstruktorga uzatamiz
          return SupplierDetailsScreen(supplier: supplier);
        },
      ),
      GoRoute(
        path: PlatformRoutes.addNewSupplierPage.route,
        builder: (context, state) => const AddSupplierScreen(),
      ),
      GoRoute(
        path: PlatformRoutes.basketPage.route,
        builder: (context, state) => const BasketScreen(),
      ),
      GoRoute(
        path: PlatformRoutes.checkoutPage.route,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: PlatformRoutes.scanProductPage.route,
        builder: (context, state) => const ScanProductScreen(),
      ),
      GoRoute(
        path: PlatformRoutes.receiptPage.route,
        builder: (context, state) => const ReceiptDetailScreen(),
      ),
      GoRoute(
        path: PlatformRoutes.salePage.route,
        builder: (context, state) => const SaleScreen(),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
