# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Ocam POS — a Flutter (Android/iOS first) point-of-sale app for shops: inventory, barcode scanning, cart/checkout, receipt printing, refunds, customers, suppliers, employees, supplier purchases (stock-in), shop expenses and a cash drawer. Backend is Firebase (Auth + Firestore), project `storepost-a64b8`. Firebase is abstracted behind a datasource layer so it can be swapped for a REST backend later without touching BLoCs or UI (see Architecture below).

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
    navigation/nav_extensions.dart# context.popOrGo(fallback) — safe back navigation
    routes/app_routes.dart        # PlatformRoutes — every path as a RouteInfo constant
    network/                      # ApiClient (future REST), FirestorePaths, Failure, AppException, NetworkInfo
    logic/                        # AppBlocObserver, BlocStatus enum
    theme/                        # AppColors, AppTextStyles, AppTheme (real ThemeData)
    utils/                        # AppFormat, Validators, AppConfig, ReceiptPrinter
    widgets/                      # app-wide reusable widgets (AppButton, AppSnackBar, BaseSheetWrapper,
                                  # showConfirmDialog, showTextInputDialog, ...)

  presentation/<feature>/         # auth, home, inventory, sale, sales_history, refunds,
                                   # purchases, expenses, supplier, customers, employee,
                                   # cashdrawer, profile, settings, notifications, more,
                                   # report, onboarding
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
users/{uid}/expenses
users/{uid}/purchases
users/{uid}/pos_settings/drawer_info
```

Every money-moving action is a single Firestore transaction that touches several of these at once — sale, refund, purchase, expense and drawer transfer all follow the same read-everything-then-write shape, and all of them are covered by `test/data/` tests against `FakeFirebaseFirestore`.

`FirestorePaths.uid` throws `UnauthenticatedException` if called with no signed-in user — datasources rely on this rather than null-checking.

### Routing

`lib/core/routes/app_routes.dart` holds every path as a `PlatformRoutes` constant; `lib/core/navigation/app_router.dart` builds the flat `GoRouter`. Always add both — a new page needs a `PlatformRoutes` constant *and* a `GoRoute`.

- Arguments are passed via `state.extra` and cast unchecked (`state.extra as ProductModel`), so `context.push(PlatformRoutes.productDetails.route, extra: product)` must pass exactly the expected model type.
- `redirect` reads `context.read<AuthBloc>().state` (`AuthState.isAuthenticated` / `isUnauthenticated`): authenticated users are bounced off the splash/login/signup paths, unauthenticated users are bounced to `/login`. Adding a screen reachable while logged out means adding it to the `isPublicPath` check.
- `initialLocation` is evaluated once from `FirebaseAuth.instance.currentUser` when `AppRouter` is first touched — this is why `main.dart` awaits `authStateChanges().first` with a 1s timeout before `runApp`.
- `HomePage` is a `persistent_bottom_nav_bar` `PersistentTabView` with 5 tabs (Home, Inventory, Sale, Supplier, More); those tab screens are *also* reachable as standalone routes.

### Sale flow

`SaleScreen` → `SaleBloc.LoadSaleProducts` → cart events (`ScanBarcodeEvent` looks a product up by barcode within the user's own `products`) → `BasketScreen` → `CheckoutScreen` → `CompleteSaleEvent`. `SaleRemoteDataSourceImpl.createSale` runs a single Firestore transaction that writes the sale doc, decrements each product's `stock`, credits the cash drawer balance (cash payments only), and updates the customer's `totalSpent` if one was attached — all or nothing. `SaleBloc` also blocks adding more of a product to the cart than its current `stock` client-side, before the transaction is ever attempted.

`createSale` writes `createdAt` as `FieldValue.serverTimestamp()` for a sale dated today, but as `Timestamp.fromDate(sale.createdAt)` when the cashier picked an earlier day on `CheckoutScreen` (backdating a sale is allowed, future dates are not).

The receipt (`core/utils/receipt_printer.dart`) takes the optional `sale` and `store` (`UserModel`) so it can print the shop header (name, address, phone, STIR) plus payment method, paid amount and change. Store details are edited in Settings and live on the user document.

### Finding an old sale

The report shows one day at a time; `/salesHistory` (`SalesHistoryBloc`, screen-local `registerFactory`) covers a date range with search over customer, cashier and receipt id, and opens the receipt for any row. Refunded rows are struck through and left out of the total.

### Refunds

`SaleRemoteDataSourceImpl.refundSale` reverses a sale in one transaction: restores each product's stock, takes the money back out of the drawer (cash sales only, and only if the drawer still holds enough), lowers the customer's `totalSpent` and flags the sale `refunded`. Refunded sales are excluded from every report total (`ReportState.countedSales`) and are listed on `/refunds`. A sale can only be refunded once.

### Purchases and expenses

- **Purchase** (`/purchases`, `PurchaseRemoteDataSourceImpl.createPurchase`) is stock-in from a supplier: it increments each product's `stock`, overwrites `buyPrice` with the price actually paid (profit maths depends on it) and, when paid from the drawer, decrements the drawer balance.
- **Expense** (`/expenses`) is money leaving the shop for rent, utilities, transport and so on; `fromDrawer` expenses decrement the drawer and give the money back if the expense is deleted.
- The daily report shows expenses and profit-after-expenses; purchases are *not* an expense there — their cost reaches the report through each product's `buyPrice` when it is sold.

### Cashiers

`EmployeeState.activeCashier` holds whoever is at the till (null = the owner). Switching is done from Profile → "Profilni almashtirish" and asks for the employee's PIN when one is set. `PinHasher` (`core/utils/pin_hasher.dart`) stores only a sha256 of `"<employeeId>:<pin>"` — the employee id is the salt, so the same PIN hashes differently per employee and a hash cannot be copied between them. This PIN is attribution, not authorization: the app's Firestore access still belongs to the owner's Firebase account. `CompleteSaleEvent` carries the active cashier so the sale document and the receipt record who sold.

### Cash drawer

`users/{uid}/pos_settings/drawer_info.current_balance` grows on every cash sale. Money leaves it through a transfer: `TransferParty` (`data/models/transfer_party_model.dart`) makes the drawer and each employee interchangeable sides of `EmployeeRemoteDataSource.transferBalance`, which updates both documents (`current_balance` for the drawer, `balance` for an employee) and appends to `transfer_logs` in one transaction. `CashState` stores only the selected party **ids** and resolves balances from the live lists, so an open form never validates against a stale balance.

## Known runtime gotcha (verified on-device, not visible from reading the code)

`ElevatedButton(shape: const CircleBorder(), ...)` inside a `Row` that sits below a `ClipPath`-clipped `Stack` (as in `presentation/onboarding/widgets/splash_content.dart`) silently fails to paint on the Impeller/OpenGLES rendering backend — no exception, no overflow warning, the whole `Row` (siblings included) just never renders, and its tap targets don't exist. Confirmed by bisection on a physical build + emulator; `RepaintBoundary` did not fix it. Workaround in place: a circular next-button built from `Material(shape: CircleBorder()) + InkWell` instead of `ElevatedButton`. If you need a circular Material button elsewhere in this app, use that pattern, not `ElevatedButton` + `CircleBorder`.

## Testing

`test/` has real unit, bloc and datasource tests (`bloc_test` + `mocktail` + `fake_cloud_firestore`), 87 in total:

- `core/utils/` — Validators, AppFormat, PinHasher (pure functions)
- `presentation/` — `auth_bloc_test.dart`, `sale_bloc_test.dart` (cart stock-limit, insufficient-payment guard), `product_state_test.dart`, `cashdrawer/cash_bloc_test.dart` (transfer validation, party resolution), `sales_history/sales_history_state_test.dart`
- `data/` — `sale_remote_datasource_test.dart` (sale + refund), `employee_remote_datasource_test.dart` (drawer transfers), `expense_remote_datasource_test.dart`, `purchase_remote_datasource_test.dart`, `customer_remote_datasource_test.dart`: real Firestore semantics (transactions, `FieldValue.increment`, `serverTimestamp`) against `FakeFirebaseFirestore`

Money-moving code belongs in `data/` with a transaction test that asserts **both** the happy path and that a rejected operation leaves every document untouched.

`test/widget_test.dart` (the unmodified counter template) was removed — it required an uninitialized Firebase and tested nothing about this app.

When adding a repository-backed BLoC test, mock the `*Repository` class directly with `mocktail` (`class MockXRepository extends Mock implements XRepository {}`) — repositories are plain classes with a single named-required-param constructor, easy to mock; don't mock the datasource layer from a BLoC test.

For a datasource test, build `FirestorePaths(db: FakeFirebaseFirestore(), auth: mockAuth)` where `mockAuth.currentUser.uid` returns a fake uid — that is the only Firebase seam the data layer needs.

## Gotchas

- **Never return `Expanded` from a widget that callers already wrap in `Expanded`** — the home tab did exactly that and Flutter reported "Incorrect use of ParentDataWidget" on every build (two `Expanded`s writing parent data to the same RenderObject). Cheap to reproduce in a widget test with `tester.takeException()`.
- Search filters live in the BLoC, but the search `TextField`s are page-local and start empty. Pages therefore dispatch their `Search…('')` event in `initState` — otherwise re-entering a list shows it filtered by a query the user can no longer see.
- Any icon that looks tappable must actually do something: the barcode icons on the product forms, the arrows in the purchase/report lists and the employee edit pencil were all decoration until they were wired up. When adding a suffix icon to an input, give it an `onTap` (`CustomTextField.onSuffixTap`, `EditInputField.onScanTap`) or don't draw it.
- `openBarcodeScanner(context)` (`presentation/sale/pages/scanner_page.dart`) is the single entry point to the camera scanner; it returns the barcode or `null`.
- Documents are created with `createdAt: FieldValue.serverTimestamp()` **only when new** (`if (isNew)`) — a `SetOptions(merge: true)` save that always writes it would reset a customer's registration date and reorder every list sorted by `createdAt`.
- `firebase_core` is a direct dependency in `pubspec.yaml` now (was previously transitive-only and unlisted).
- `SignUpBloc`-equivalent dead code has been removed. An alternate swipeable `PageView` onboarding (`onboarding_page.dart` + `OnboardingBloc`) was also removed — it was unrouted, still had the `ElevatedButton(shape: CircleBorder())` rendering bug (see below) unfixed, and was in English. The three routed splash pages (`first_splash_page.dart` / `second_splash_page.dart` / `third_splash_page.dart`, all built on `splash_content.dart`) are the only onboarding flow now.
- A few screens (`presentation/profile/pages/select_profile_page.dart`'s "switch profile" flow) are intentionally wired to real data (employee list) but the actual "switch" action is a no-op placeholder — multi-cashier device switching needs a PIN/security design decision that hasn't been made yet.
- The remaining `AppSnackBar.info(context, "Tez orada qo'shiladi")` placeholders are features that need a package or a backend that does not exist yet: contact import (customers, suppliers — needs a contacts plugin and permissions), social login, loyalty programme, coupons, invoices, language switching, help centre/FAQ, customer "share". Everything else that looked like a placeholder has been implemented — check before adding another one.
- `AppConfig.currency` is a **mutable global** (not a const): it is set from the loaded profile by `CurrencyScope` in `main.dart` and read by `AppFormat.money`. Money formatting happens outside the widget tree (PDF receipts, BLoC messages), which is why it is not an InheritedWidget; `CurrencyScope` rebuilds the app when the setting changes so nothing shows a stale symbol.
- Colors come from `AppColors` constants (`core/theme/app_colors.dart`) but there is now a real `AppTheme.light` (`core/theme/app_theme.dart`) wired into `MaterialApp.router` — prefer using themed defaults (`ElevatedButton`, `TextFormField`, etc. already pick up the right colors) over hardcoding `AppColors.x` in new widgets where a theme default exists.
