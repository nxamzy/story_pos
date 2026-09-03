import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:ocam_pos/core/logic/app_bloc_observer.dart';
import 'package:ocam_pos/core/navigation/app_router.dart';
import 'package:ocam_pos/core/theme/app_theme.dart';
import 'package:ocam_pos/core/utils/app_config.dart';
import 'package:ocam_pos/injection.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_bloc.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_state.dart';
import 'package:ocam_pos/presentation/cashdrawer/bloc/cash_bloc.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_bloc.dart';
import 'package:ocam_pos/presentation/employee/bloc/employee_bloc.dart';
import 'package:ocam_pos/presentation/expenses/bloc/expense_bloc.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_bloc.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_event.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_bloc.dart';
import 'package:ocam_pos/presentation/purchases/bloc/purchase_bloc.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_event.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_state.dart';
import 'package:ocam_pos/presentation/report/bloc/report_bloc.dart';
import 'package:ocam_pos/presentation/sale/bloc/sale_bloc.dart';
import 'package:ocam_pos/presentation/supplier/bloc/supplier_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureDependencies();

  // Oy/kun nomlari (DateFormat'dagi 'MMMM', 'EEEE' kabi) shu ishga
  // tushirilmasa har doim inglizcha chiqadi — butun ilova o'zbekcha
  // bo'lgani uchun standart til ham shunga moslanadi.
  await initializeDateFormatting('uz');
  Intl.defaultLocale = 'uz';

  if (kDebugMode) Bloc.observer = const AppBlocObserver();

  await FirebaseAuth.instance.authStateChanges().first.timeout(
    const Duration(milliseconds: 1000),
    onTimeout: () => null,
  );

  runApp(const MyApp());
}

/// Butun ilova uchun bitta marta yaratiladigan BLoC'lar.
///
/// GoRouter'dagi barcha yo'llar tekis (flat) — bitta ekrandan ikkinchisiga
/// `context.push` bilan o'tilganda avvalgi widget daraxti qoladi, lekin u
/// ostidagi BlocProvider endi ko'rinmaydi. Shu sababli har bir BLoC shu
/// yerda — ildizda — bir marta ta'minlanadi va butun ilova bo'ylab bir xil
/// nusxa ishlatiladi (`context.read<XBloc>()` qayerdan chaqirilishidan
/// qat'i nazar bir xil obyektni qaytaradi).
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AuthBloc>()),
        BlocProvider.value(value: sl<ProfileBloc>()),
        BlocProvider.value(value: sl<ProductBloc>()..add(const LoadProducts())),
        BlocProvider.value(value: sl<SaleBloc>()),
        BlocProvider.value(value: sl<CustomerBloc>()),
        BlocProvider.value(value: sl<SupplierBloc>()),
        BlocProvider.value(value: sl<EmployeeBloc>()),
        BlocProvider.value(value: sl<CashBloc>()),
        BlocProvider.value(value: sl<ExpenseBloc>()),
        BlocProvider.value(value: sl<PurchaseBloc>()),
        BlocProvider.value(value: sl<ReportBloc>()),
      ],
      // Profil ma'lumoti (ism, email) Home ekranidagi sarlavhada ko'rinadi,
      // lekin foydalanuvchi hali Profil sahifasiga kirmagan bo'lishi mumkin.
      // Shu sababli har safar sessiya "Authenticated" bo'lganda profil
      // avtomatik yuklanadi — Home ekrani "Yuklanmoqda..." holatida qolib
      // ketmaydi.
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            !previous.isAuthenticated && current.isAuthenticated,
        listener: (context, state) =>
            context.read<ProfileBloc>().add(const LoadUserProfile()),
        child: const CurrencyScope(child: AppContent()),
      ),
    );
  }
}

/// Do'kon valyutasini `AppConfig`ga o'rnatib turadi.
///
/// `AppFormat.money` valyutani `AppConfig`dan o'qiydi (u global qiymat,
/// chunki narx formatlash butun ilovada, widget daraxtidan tashqarida ham
/// ishlatiladi). Sozlamada valyuta o'zgarganda shu joy ilovani qayta
/// chizadi — aks holda eski belgi ekranda qolib ketardi.
class CurrencyScope extends StatefulWidget {
  final Widget child;

  const CurrencyScope({super.key, required this.child});

  @override
  State<CurrencyScope> createState() => _CurrencyScopeState();
}

class _CurrencyScopeState extends State<CurrencyScope> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.user?.currency != current.user?.currency,
      listener: (context, state) {
        final currency = state.user?.currency;
        setState(() {
          AppConfig.currency = (currency == null || currency.isEmpty)
              ? AppConfig.defaultCurrency
              : currency;
        });
      },
      child: widget.child,
    );
  }
}

class AppContent extends StatelessWidget {
  const AppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Ocam POS',
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
