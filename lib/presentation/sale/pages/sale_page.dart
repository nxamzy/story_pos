import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/presentation/sale/bloc/sale_bloc.dart';
import 'package:ocam_pos/presentation/sale/bloc/sale_event.dart';
import 'package:ocam_pos/presentation/sale/bloc/sale_state.dart';
import 'package:ocam_pos/presentation/sale/widgets/quick_add_sheet.dart';
import 'package:ocam_pos/presentation/sale/pages/scanner_page.dart';
import 'package:ocam_pos/presentation/sale/widgets/sale_product_grid.dart';
import 'package:ocam_pos/presentation/sale/widgets/category_list.dart';
import 'package:ocam_pos/presentation/sale/widgets/sale_header.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final TextEditingController searchController = TextEditingController();
  final Map<String, DateTime> _lastScanTimes = {};

  @override
  void initState() {
    super.initState();
    context.read<SaleBloc>()
      ..add(const LoadSaleProducts())
      // Qidiruv maydoni bo'sh — BLoC'dagi eski so'rov ham tozalanadi.
      ..add(const SearchSaleProducts(''));
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _onBarcodeScanned(String barcode) async {
    final now = DateTime.now();
    final lastScan = _lastScanTimes[barcode];
    // Bir xil shtrix-kod ketma-ket 2 soniya ichida qayta o'qilsa —
    // savatga ikki marta qo'shilib ketmasligi uchun e'tiborsiz qoldiriladi.
    if (lastScan != null && now.difference(lastScan).inSeconds < 2) return;
    _lastScanTimes[barcode] = now;

    await HapticFeedback.mediumImpact();
    if (mounted) {
      context.read<SaleBloc>().add(ScanBarcodeEvent(barcode));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<SaleBloc, SaleState>(
        listenWhen: (previous, current) => current.error != previous.error,
        listener: (context, state) {
          if (state.error != null) {
            AppSnackBar.error(context, state.error!);
            context.read<SaleBloc>().add(const SaleMessageCleared());
          }
        },
        child: Column(
          children: [
            const SaleHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    BlocBuilder<SaleBloc, SaleState>(
                      buildWhen: (p, c) =>
                          p.categories != c.categories ||
                          p.category != c.category,
                      builder: (context, state) => CategoryList(
                        categories: state.categories,
                        selected: state.category,
                        onCategorySelected: (category) => context
                            .read<SaleBloc>()
                            .add(FilterSaleByCategory(category)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSearchSection(),
                    const SizedBox(height: 20),
                    _buildCartSummary(),
                    const SizedBox(height: 20),
                    _buildGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary() {
    return BlocBuilder<SaleBloc, SaleState>(
      buildWhen: (p, c) =>
          p.cartItems != c.cartItems || p.totalAmount != c.totalAmount,
      builder: (context, state) {
        if (state.isCartEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Savatda: ${state.totalQuantity} mahsulot"),
                    Text(
                      AppFormat.money(state.totalAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.push(PlatformRoutes.basketPage.route),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Savatga o'tish",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: 55,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.mintLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Mahsulot qidirish",
                        hintStyle: TextStyle(color: AppColors.sage),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) => context.read<SaleBloc>().add(
                        SearchSaleProducts(value),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          context.read<SaleBloc>().add(ScanBarcodeEvent(value));
                          searchController.clear();
                          context.read<SaleBloc>().add(
                            const SearchSaleProducts(''),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => showQuickAddProductSheet(context),
            child: _iconButton(Icons.add),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () async {
              final scannedBarcode = await openBarcodeScanner(context);
              if (scannedBarcode != null && scannedBarcode.isNotEmpty) {
                await _onBarcodeScanned(scannedBarcode);
              }
            },
            child: _iconButton(Icons.qr_code_scanner),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Mahsulot topilmadi",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.forestDark,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Qidiruv so'zini tekshiring yoki\nboshqa kategoriya tanlang.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.sage, fontSize: 14),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.mintLight),
      ),
      child: Icon(icon, color: AppColors.primary),
    );
  }

  Widget _buildGrid() {
    return BlocBuilder<SaleBloc, SaleState>(
      builder: (context, state) {
        if (state.status.isFirstLoad && state.products.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 50),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final displayProducts = state.visibleProducts;

        if (displayProducts.isEmpty) {
          return _buildEmptyState();
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
          ),
          itemCount: displayProducts.length,
          itemBuilder: (context, index) {
            return ProductCard(product: displayProducts[index]);
          },
        );
      },
    );
  }
}
