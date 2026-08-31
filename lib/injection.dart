import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'package:ocam_pos/core/network/api_client.dart';
import 'package:ocam_pos/core/network/firestore_paths.dart';
import 'package:ocam_pos/core/network/network_info.dart';
import 'package:ocam_pos/core/utils/app_config.dart';

import 'package:ocam_pos/data/datasources/auth_remote_datasource.dart';
import 'package:ocam_pos/data/datasources/customer_remote_datasource.dart';
import 'package:ocam_pos/data/datasources/employee_remote_datasource.dart';
import 'package:ocam_pos/data/datasources/product_remote_datasource.dart';
import 'package:ocam_pos/data/datasources/sale_remote_datasource.dart';
import 'package:ocam_pos/data/datasources/supplier_remote_datasource.dart';
import 'package:ocam_pos/data/datasources/user_remote_datasource.dart';

import 'package:ocam_pos/data/repositories/auth_repository.dart';
import 'package:ocam_pos/data/repositories/customer_repository.dart';
import 'package:ocam_pos/data/repositories/employee_repository.dart';
import 'package:ocam_pos/data/repositories/product_repository.dart';
import 'package:ocam_pos/data/repositories/sale_repository.dart';
import 'package:ocam_pos/data/repositories/supplier_repository.dart';
import 'package:ocam_pos/data/repositories/user_repository.dart';

import 'package:ocam_pos/presentation/auth/bloc/auth_bloc.dart';
import 'package:ocam_pos/presentation/cashdrawer/bloc/cash_bloc.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_bloc.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_sales_bloc.dart';
import 'package:ocam_pos/presentation/employee/bloc/employee_bloc.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_bloc.dart';
import 'package:ocam_pos/presentation/onboarding/bloc/onboarding_bloc.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_bloc.dart';
import 'package:ocam_pos/presentation/report/bloc/report_bloc.dart';
import 'package:ocam_pos/presentation/sale/bloc/sale_bloc.dart';
import 'package:ocam_pos/presentation/supplier/bloc/supplier_bloc.dart';

/// Butun ilovaning bog'liqliklari shu yerda ro'yxatdan o'tadi.
///
/// Qoida: UI hech qachon `FirebaseFirestore.instance` ni chaqirmaydi.
/// UI -> BLoC -> Repository -> DataSource -> Firebase.
/// Backend almashsa, faqat `*_remote_datasource.dart` fayllari o'zgaradi.
final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  // ---------- Tashqi paketlar ----------
  sl
    ..registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance)
    ..registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance)
    ..registerLazySingleton<FirestorePaths>(
      () => FirestorePaths(db: sl(), auth: sl()),
    )
    ..registerLazySingleton<NetworkInfo>(() => const NetworkInfoImpl())
    ..registerLazySingleton<ApiClient>(
      () => HttpApiClient(
        baseUrl: AppConfig.apiBaseUrl,
        tokenProvider: () async => sl<FirebaseAuth>().currentUser?.getIdToken(),
      ),
    );

  // ---------- DataSource'lar ----------
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(auth: sl(), paths: sl()),
    )
    ..registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl(paths: sl()),
    )
    ..registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(paths: sl()),
    )
    ..registerLazySingleton<CustomerRemoteDataSource>(
      () => CustomerRemoteDataSourceImpl(paths: sl()),
    )
    ..registerLazySingleton<SupplierRemoteDataSource>(
      () => SupplierRemoteDataSourceImpl(paths: sl()),
    )
    ..registerLazySingleton<SaleRemoteDataSource>(
      () => SaleRemoteDataSourceImpl(paths: sl()),
    )
    ..registerLazySingleton<EmployeeRemoteDataSource>(
      () => EmployeeRemoteDataSourceImpl(paths: sl()),
    );

  // ---------- Repository'lar ----------
  sl
    ..registerLazySingleton<AuthRepository>(() => AuthRepository(remote: sl()))
    ..registerLazySingleton<UserRepository>(() => UserRepository(remote: sl()))
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepository(remote: sl()),
    )
    ..registerLazySingleton<CustomerRepository>(
      () => CustomerRepository(remote: sl()),
    )
    ..registerLazySingleton<SupplierRepository>(
      () => SupplierRepository(remote: sl()),
    )
    ..registerLazySingleton<SaleRepository>(() => SaleRepository(remote: sl()))
    ..registerLazySingleton<EmployeeRepository>(
      () => EmployeeRepository(remote: sl()),
    );

  // ---------- BLoC'lar ----------
  // GoRouter'dagi barcha yo'llar tekis (flat) — ichma-ich emas. Shu sababli
  // BLoC'lar `main.dart` ildizida bitta marta ta'minlanadi (singleton):
  // aks holda boshqa route'ga o'tilganda oldingi ekranning BlocProvider'i
  // qolib ketib, "Provider topilmadi" xatosi chiqadi.
  sl
    ..registerLazySingleton<AuthBloc>(() => AuthBloc(authRepository: sl()))
    ..registerLazySingleton<SaleBloc>(
      () => SaleBloc(productRepository: sl(), saleRepository: sl()),
    )
    ..registerLazySingleton<ProfileBloc>(() => ProfileBloc(userRepository: sl()))
    ..registerLazySingleton<ProductBloc>(() => ProductBloc(repository: sl()))
    ..registerLazySingleton<CustomerBloc>(() => CustomerBloc(repository: sl()))
    ..registerLazySingleton<SupplierBloc>(() => SupplierBloc(repository: sl()))
    ..registerLazySingleton<EmployeeBloc>(() => EmployeeBloc(repository: sl()))
    ..registerLazySingleton<CashBloc>(() => CashBloc(repository: sl()))
    ..registerLazySingleton<ReportBloc>(() => ReportBloc(saleRepository: sl()))
    ..registerLazySingleton<OnboardingBloc>(() => OnboardingBloc());

  // Sahifa-lokal BLoC — faqat bitta ekranga tegishli, shu sababli har safar
  // yangi nusxa (`registerFactory`) va `main.dart`dagi umumiy
  // MultiBlocProvider'da emas, o'sha sahifaning o'zida ta'minlanadi.
  sl.registerFactory<CustomerSalesBloc>(
    () => CustomerSalesBloc(repository: sl()),
  );
}

/// Testlarda holatni tozalash uchun.
Future<void> resetDependencies() => sl.reset();
