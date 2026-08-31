# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Ocam POS — a Flutter (Android/iOS first) point-of-sale app for shops: inventory, barcode scanning, cart/checkout, receipt printing, customers, suppliers, employees and a cash drawer. Backend is Firebase (Auth + Firestore), project `storepost-a64b8`. Firebase is abstracted behind a datasource layer so it can be swapped for a REST backend later without touching BLoCs or UI (see Architecture below).

**UI text, error messages and code comments are written in Uzbek.** Keep new user-facing strings in Uzbek to stay consistent.

## Commands

```bash
flutter pub get
flutter run                      # attached device/emulator
flutter analyze                  # baseline: 0 issues
flutter test                     # unit + bloc tests under test/
flutter build apk --debug        # real compile check; --debug builds install fine without release signing
flutterfire configure            # regenerates lib/firebase_options.dart + google-services.json
```

`android/app/google-services.json` is gitignored but required for Android builds — a fresh clone must run `flutterfire configure`. `lib/firebase_options.dart` is committed.

Toolchain in use: Flutter 3.38.5 / Dart 3.10.4, SDK constraint `^3.10.4`.

## Architecture

Strict three-layer structure under `lib/`, plus a root-level `injection.dart`. This layout is the user's fixed personal convention — keep new code inside it rather than introducing alternatives.

```
lib/
  injection.dart                  # get_it DI container, manual registration (no build_runner)
  main.dart                       # Firebase init, configureDependencies(), global BlocProviders, MaterialApp.router

  core/
    navigation/app_router.dart    # GoRouter instance, auth redirect
    routes/app_routes.dart        # PlatformRoutes — every path as a RouteInfo constant
    network/                      # ApiClient (future REST), FirestorePaths, Failure, AppException, NetworkInfo
    logic/                        # AppBlocObserver, BlocStatus enum
    theme/                        # AppColors, AppTextStyles, AppTheme (real ThemeData)
    utils/                        # AppFormat, Validators, AppConfig, ReceiptPrinter
    widgets/                      # app-wide reusable widgets (AppButton, AppSnackBar, BaseSheetWrapper, ...)

  presentation/<feature>/         # auth, home, inventory, sale, supplier, customers, employee,
                                   # cashdrawer, profile, settings, notifications, more, report, onboarding
    bloc/                         # <feature>_bloc.dart + <feature>_event.dart + <feature>_state.dart — always 3 files
    pages/
    widgets/

  data/
    datasources/                  # *_remote_datasource.dart — the ONLY files that call Firebase directly
    models/                       # fromMap(map, docId) / toMap(), Equatable, ModelUtils for safe parsing
    repositories/                 # thin wrapper: calls datasource, converts errors to Failure via RepositoryGuard
```

**Data flow is one-directional and never skips a layer:** UI → BLoC → Repository → DataSource → Firebase. No page or widget calls `FirebaseFirestore.instance`/`FirebaseAuth.instance` directly — grep for `Firebase` outside `lib/data/` and `lib/core/network/` if you see one, it's a bug.

### BLoC convention

Every feature's `bloc/` folder has exactly three files, never combined:
- `<feature>_bloc.dart` — extends `Bloc<XEvent, XState>`, takes its repository via constructor injection
- `<feature>_event.dart` — `Equatable` event classes
- `<feature>_state.dart` — one `Equatable` state class with a `BlocStatus status` field (`core/logic/bloc_status.dart`) and `copyWith`

BLoCs that need to survive across the app (auth session, cart, product list feeding both Sale and Inventory, etc.) are registered as `registerLazySingleton` in `injection.dart` and provided once in `main.dart`'s `MultiBlocProvider` — **not** per-page. This is because `lib/core/navigation/app_router.dart` is a flat `GoRouter` (no nested/shell routes): pushing a new page does not dispose the page underneath, so a BlocProvider scoped to one page would go out of `context.read` reach from a pushed page without actually being disposed, and re-creating one per page would silently reset state (cart, filters) on every navigation. Screen-local BLoCs (nothing else needs them) still get `BlocProvider(create: ...)` at the page level.

### Firestore layout and tenancy

Everything is nested under `users/{uid}/...` (see `core/network/firestore_paths.dart` — `FirestorePaths` is the single place `collection()` is called; nothing else should hardcode a Firestore path):

```
users/{uid}/products
users/{uid}/customers
users/{uid}/suppliers
users/{uid}/sales
users/{uid}/employees
users/{uid}/transfer_logs
users/{uid}/pos_settings/drawer_info
```

`FirestorePaths.uid` throws `UnauthenticatedException` if called with no signed-in user — datasources rely on this rather than null-checking.

### Routing

`lib/core/routes/app_routes.dart` holds every path as a `PlatformRoutes` constant; `lib/core/navigation/app_router.dart` builds the flat `GoRouter`. Always add both — a new page needs a `PlatformRoutes` constant *and* a `GoRoute`.

- Arguments are passed via `state.extra` and cast unchecked (`state.extra as ProductModel`), so `context.push(PlatformRoutes.productDetails.route, extra: product)` must pass exactly the expected model type.
- `redirect` reads `context.read<AuthBloc>().state` (`AuthState.isAuthenticated` / `isUnauthenticated`): authenticated users are bounced off the splash/login/signup paths, unauthenticated users are bounced to `/login`. Adding a screen reachable while logged out means adding it to the `isPublicPath` check.
- `initialLocation` is evaluated once from `FirebaseAuth.instance.currentUser` when `AppRouter` is first touched — this is why `main.dart` awaits `authStateChanges().first` with a 1s timeout before `runApp`.
- `HomePage` is a `persistent_bottom_nav_bar` `PersistentTabView` with 5 tabs (Home, Inventory, Sale, Supplier, More); those tab screens are *also* reachable as standalone routes.

### Sale flow

`SaleScreen` → `SaleBloc.LoadSaleProducts` → cart events (`ScanBarcodeEvent` looks a product up by barcode within the user's own `products`) → `BasketScreen` → `CheckoutScreen` → `CompleteSaleEvent`. `SaleRemoteDataSourceImpl.createSale` runs a single Firestore transaction that writes the sale doc, decrements each product's `stock`, credits the cash drawer balance (cash payments only), and updates the customer's `totalSpent` if one was attached — all or nothing. `SaleBloc` also blocks adding more of a product to the cart than its current `stock` client-side, before the transaction is ever attempted.

## Known runtime gotcha (verified on-device, not visible from reading the code)

`ElevatedButton(shape: const CircleBorder(), ...)` inside a `Row` that sits below a `ClipPath`-clipped `Stack` (as in `presentation/onboarding/widgets/splash_content.dart`) silently fails to paint on the Impeller/OpenGLES rendering backend — no exception, no overflow warning, the whole `Row` (siblings included) just never renders, and its tap targets don't exist. Confirmed by bisection on a physical build + emulator; `RepaintBoundary` did not fix it. Workaround in place: a circular next-button built from `Material(shape: CircleBorder()) + InkWell` instead of `ElevatedButton`. If you need a circular Material button elsewhere in this app, use that pattern, not `ElevatedButton` + `CircleBorder`.

## Testing

`test/` has real unit and bloc tests (`bloc_test` + `mocktail`): `core/utils/` (Validators, AppFormat — pure functions), `presentation/auth/auth_bloc_test.dart`, `presentation/sale/sale_bloc_test.dart` (cart stock-limit enforcement, insufficient-payment guard), `presentation/inventory/product_state_test.dart`. `test/widget_test.dart` (the unmodified counter template) has been removed — it required an uninitialized Firebase and tested nothing about this app.

When adding a repository-backed BLoC test, mock the `*Repository` class directly with `mocktail` (`class MockXRepository extends Mock implements XRepository {}`) — repositories are plain classes with a single named-required-param constructor, easy to mock; don't mock the datasource layer from a BLoC test.

## Gotchas

- `firebase_core` is a direct dependency in `pubspec.yaml` now (was previously transitive-only and unlisted).
- `SignUpBloc`-equivalent dead code has been removed. An alternate swipeable `PageView` onboarding (`onboarding_page.dart` + `OnboardingBloc`) was also removed — it was unrouted, still had the `ElevatedButton(shape: CircleBorder())` rendering bug (see below) unfixed, and was in English. The three routed splash pages (`first_splash_page.dart` / `second_splash_page.dart` / `third_splash_page.dart`, all built on `splash_content.dart`) are the only onboarding flow now.
- A few screens (`presentation/profile/pages/select_profile_page.dart`'s "switch profile" flow) are intentionally wired to real data (employee list) but the actual "switch" action is a no-op placeholder — multi-cashier device switching needs a PIN/security design decision that hasn't been made yet.
- Colors come from `AppColors` constants (`core/theme/app_colors.dart`) but there is now a real `AppTheme.light` (`core/theme/app_theme.dart`) wired into `MaterialApp.router` — prefer using themed defaults (`ElevatedButton`, `TextFormField`, etc. already pick up the right colors) over hardcoding `AppColors.x` in new widgets where a theme default exists.
