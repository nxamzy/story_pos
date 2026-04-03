import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/presentation/bloc/billing_bloc.dart';
import 'package:ocam_pos/logic/blocs/auth/auth_bloc.dart';
import 'package:ocam_pos/logic/blocs/products/product_bloc.dart';
import 'package:ocam_pos/logic/blocs/products/product_event.dart';
import 'package:ocam_pos/presentation/bloc/profile/profile_bloc.dart';
import 'package:ocam_pos/presentation/pages/customers/bloc/customer_bloc.dart';
import 'package:ocam_pos/routes/app_route.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAuth.instance.authStateChanges().first.timeout(
    const Duration(milliseconds: 1000),
    onTimeout: () => null,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => ProfileBloc()),
        BlocProvider(create: (context) => ProductBloc()..add(LoadProducts())),
        BlocProvider<BillingBloc>(create: (context) => BillingBloc()),
        BlocProvider(create: (context) => CustomerBloc()),
      ],
      child: const AppContent(),
    );
  }
}

class AppContent extends StatelessWidget {
  const AppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
