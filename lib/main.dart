import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ocam_pos/core/logic/app_bloc_observer.dart';
import 'package:ocam_pos/core/navigation/app_router.dart';
import 'package:ocam_pos/core/theme/app_theme.dart';
import 'package:ocam_pos/injection.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_bloc.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_state.dart';
import 'package:ocam_pos/presentation/cashdrawer/bloc/cash_bloc.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_bloc.dart';
import 'package:ocam_pos/presentation/employee/bloc/employee_bloc.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_bloc.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_event.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_bloc.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_event.dart';
import 'package:ocam_pos/presentation/report/bloc/report_bloc.dart';
import 'package:ocam_pos/presentation/sale/bloc/sale_bloc.dart';
import 'package:ocam_pos/presentation/supplier/bloc/supplier_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureDependencies();

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
        BlocProvider.value(
          value: sl<ProductBloc>()..add(const LoadProducts()),
        ),
        BlocProvider.value(value: sl<SaleBloc>()),
        BlocProvider.value(value: sl<CustomerBloc>()),
        BlocProvider.value(value: sl<SupplierBloc>()),
        BlocProvider.value(value: sl<EmployeeBloc>()),
        BlocProvider.value(value: sl<CashBloc>()),
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
        child: const AppContent(),
      ),
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
