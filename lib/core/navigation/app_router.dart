import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/data/models/customer_model.dart';
import 'package:ocam_pos/data/models/employee_model.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'package:ocam_pos/data/models/sale_model.dart';
import 'package:ocam_pos/data/models/supplier_model.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_bloc.dart';

import 'package:ocam_pos/presentation/cashdrawer/pages/cashdrawer_page.dart';
import 'package:ocam_pos/presentation/customers/pages/add_customer_page.dart';
import 'package:ocam_pos/presentation/customers/pages/customer_details_page.dart';
import 'package:ocam_pos/presentation/customers/pages/customers_page.dart';
import 'package:ocam_pos/presentation/employee/pages/employee_page.dart';
import 'package:ocam_pos/presentation/employee/pages/add_employee_page.dart';
import 'package:ocam_pos/presentation/home/pages/home_page.dart';
import 'package:ocam_pos/presentation/inventory/pages/add_product_page.dart';
import 'package:ocam_pos/presentation/inventory/pages/inventory_page.dart';
import 'package:ocam_pos/presentation/inventory/pages/product_details_page.dart';
import 'package:ocam_pos/presentation/notifications/pages/notifications_page.dart';
import 'package:ocam_pos/presentation/profile/pages/profile_page.dart';
import 'package:ocam_pos/presentation/profile/pages/show_all_profiles_page.dart';
import 'package:ocam_pos/presentation/expenses/pages/expenses_page.dart';
import 'package:ocam_pos/presentation/purchases/pages/add_purchase_page.dart';
import 'package:ocam_pos/presentation/purchases/pages/purchases_page.dart';
import 'package:ocam_pos/presentation/refunds/pages/refunds_page.dart';
import 'package:ocam_pos/presentation/sales_history/pages/sales_history_page.dart';
import 'package:ocam_pos/presentation/report/pages/report_page.dart';
import 'package:ocam_pos/presentation/sale/pages/basket_page.dart';
import 'package:ocam_pos/presentation/sale/pages/checkout_page.dart';
import 'package:ocam_pos/presentation/sale/pages/sale_page.dart';
import 'package:ocam_pos/presentation/sale/pages/receipt_page.dart';
import 'package:ocam_pos/presentation/profile/pages/roles_page.dart';
import 'package:ocam_pos/presentation/settings/pages/settings_page.dart';
import 'package:ocam_pos/presentation/support/pages/faq_page.dart';
import 'package:ocam_pos/presentation/support/pages/help_page.dart';
import 'package:ocam_pos/presentation/auth/pages/change_password_page.dart';
import 'package:ocam_pos/presentation/auth/pages/forgot_password_page.dart';
import 'package:ocam_pos/presentation/auth/pages/sign_in_page.dart';
import 'package:ocam_pos/presentation/auth/pages/sign_up_page.dart';
import 'package:ocam_pos/presentation/onboarding/pages/first_splash_page.dart';
import 'package:ocam_pos/presentation/onboarding/pages/second_splash_page.dart';
import 'package:ocam_pos/presentation/onboarding/pages/third_splash_page.dart';
import 'package:ocam_pos/presentation/supplier/pages/add_supplier_page.dart';
import 'package:ocam_pos/presentation/supplier/pages/supplier_page.dart';
import 'package:ocam_pos/presentation/supplier/pages/supplier_details_page.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: FirebaseAuth.instance.currentUser != null
        ? PlatformRoutes.homePage.route
        : PlatformRoutes.firstPage.route,

    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),

    redirect: (BuildContext context, GoRouterState state) {
      final authState = context.read<AuthBloc>().state;
      final String currentLocation = state.matchedLocation;

      final bool isPublicPath =
          currentLocation == PlatformRoutes.firstPage.route ||
          currentLocation == PlatformRoutes.secondsPage.route ||
          currentLocation == PlatformRoutes.thirtPage.route ||
          currentLocation == PlatformRoutes.loginPage.route ||
          currentLocation == PlatformRoutes.signUpPage.route;

      if (authState.isAuthenticated && isPublicPath) {
        return PlatformRoutes.homePage.route;
      }

      if (authState.isUnauthenticated && !isPublicPath) {
        return PlatformRoutes.loginPage.route;
      }

      return null;
    },

    routes: [
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

      GoRoute(
        path: PlatformRoutes.homePage.route,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: PlatformRoutes.addEmployee.route,
        builder: (context, state) => const EmployeeAddPage(),
      ),
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
        path: PlatformRoutes.chanegePassword.route,
        builder: (context, state) => const ChangePasswordPage(),
      ),

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
      GoRoute(
        path: PlatformRoutes.rolesPage.route,
        builder: (context, state) => const RolesPage(),
      ),
      GoRoute(
        path: PlatformRoutes.helpPage.route,
        builder: (context, state) => const HelpPage(),
      ),
      GoRoute(
        path: PlatformRoutes.faqPage.route,
        builder: (context, state) => const FaqPage(),
      ),

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
          final customer = state.extra as CustomerModel;

          return CustomerDetailsPage(customer: customer);
        },
      ),
      GoRoute(
        path: PlatformRoutes.addNewCustomerPage.route,
        builder: (context, state) => const AddNewCustomerPage(),
      ),
      GoRoute(
        path: PlatformRoutes.employeeHRMPage.route,
        builder: (context, state) =>
            EmployeeHRMScreen(employee: state.extra as EmployeeModel?),
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
          final product = state.extra as ProductModel;

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
          final supplier = state.extra as SupplierModel;

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
        path: PlatformRoutes.receiptPage.route,
        // `extra` berilmasa — oxirgi yakunlangan savdo ko'rsatiladi.
        builder: (context, state) =>
            ReceiptDetailScreen(sale: state.extra as SaleModel?),
      ),
      GoRoute(
        path: PlatformRoutes.refundsPage.route,
        builder: (context, state) => const RefundsPage(),
      ),
      GoRoute(
        path: PlatformRoutes.expensesPage.route,
        builder: (context, state) => const ExpensesPage(),
      ),
      GoRoute(
        path: PlatformRoutes.purchasesPage.route,
        builder: (context, state) => const PurchasesPage(),
      ),
      GoRoute(
        path: PlatformRoutes.addPurchasePage.route,
        builder: (context, state) => const AddPurchasePage(),
      ),
      GoRoute(
        path: PlatformRoutes.salesHistoryPage.route,
        builder: (context, state) => const SalesHistoryPage(),
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
