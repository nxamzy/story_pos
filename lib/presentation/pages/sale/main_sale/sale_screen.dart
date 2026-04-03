import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/presentation/bloc/billing_bloc.dart';
import 'package:ocam_pos/presentation/pages/sale/main_sale/quikadd/quick_add.dart';
import 'package:ocam_pos/presentation/pages/sale/main_sale/scanner/scanner_page.dart';
import 'package:ocam_pos/presentation/pages/sale/product_card.dart';
import 'package:ocam_pos/presentation/widgets/sale_widget/main_sale/category_list.dart';
import 'package:ocam_pos/presentation/widgets/sale_widget/main_sale/sale_header.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final TextEditingController barcodeController = TextEditingController();
  final Map<String, DateTime> _lastScanTimes = {};
  String _selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    _loadInitialProducts();
  }

  void _loadInitialProducts() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<BillingBloc>().add(LoadAllProductsEvent(user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<BillingBloc, BillingState>(
        listenWhen: (previous, current) =>
            previous.error != current.error && current.error != null,
        listener: (context, state) {
          if (state.error != null && state.error!.contains("muvaffaqiyatli")) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Sotuv yakunlandi!"),
                backgroundColor: Colors.green,
              ),
            );

            final userId = FirebaseAuth.instance.currentUser?.uid;
            if (userId != null) {
              context.read<BillingBloc>().add(LoadAllProductsEvent(userId));
            }
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
                    CategoryList(
                      onCategorySelected: (category) {
                        setState(() {
                          _selectedCategory = category;
                        });
                        context.read<BillingBloc>().add(
                          FilterProductsByCategoryEvent(category),
                        );
                      },
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
    return BlocBuilder<BillingBloc, BillingState>(
      builder: (context, state) {
        if (state.cartItems.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Savatda: ${state.cartItems.length} mahsulot"),
                    Text(
                      "${state.totalAmount.toStringAsFixed(2)} EGP",
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
                    onPressed: () {
                      final userId = FirebaseAuth.instance.currentUser?.uid;
                      if (userId != null) {
                        context.read<BillingBloc>().add(
                          ConfirmSaleEvent(userId),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Confirm & Pay",
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
                      controller: barcodeController,
                      decoration: const InputDecoration(
                        hintText: "Search Product Here",
                        hintStyle: TextStyle(color: AppColors.sage),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          context.read<BillingBloc>().add(
                            ScanBarcodeEvent(value),
                          );
                          barcodeController.clear();
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
            onTap: () => bottomsheetdfsdfa(context),
            child: _iconButton(Icons.add),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () async {
              final String? scannedBarcode = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScannerPage()),
              );

              if (scannedBarcode != null && scannedBarcode.isNotEmpty) {
                final now = DateTime.now();
                if (_lastScanTimes.containsKey(scannedBarcode)) {
                  final lastScan = _lastScanTimes[scannedBarcode]!;
                  if (now.difference(lastScan).inSeconds < 2) return;
                }
                _lastScanTimes[scannedBarcode] = now;
                await HapticFeedback.mediumImpact();

                if (mounted) {
                  context.read<BillingBloc>().add(
                    ScanBarcodeEvent(scannedBarcode),
                  );
                }
              }
            },
            child: _iconButton(Icons.qr_code_scanner),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
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
    return BlocBuilder<BillingBloc, BillingState>(
      builder: (context, state) {
        if (state.isLoading && state.products.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 50),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final displayProducts = state.products;

        if (displayProducts.isEmpty) {
          return _buildEmptyState(context);
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
