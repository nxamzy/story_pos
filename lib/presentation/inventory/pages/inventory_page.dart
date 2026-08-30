import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_bloc.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_event.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_state.dart';
import 'package:ocam_pos/presentation/inventory/widgets/inventory_product_card.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push(PlatformRoutes.addNewProduct.route),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocListener<ProductBloc, ProductState>(
        listenWhen: (previous, current) => current.error != previous.error,
        listener: (context, state) {
          if (state.error != null) {
            AppSnackBar.error(context, state.error!);
          }
        },
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchSection(),
            _buildCategorySection(),
            _buildListHeader(),
            Expanded(child: _buildProductList()),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state.status.isFirstLoad && state.products.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final products = state.visibleProducts;

        if (products.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          physics: const BouncingScrollPhysics(),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return InventoryProductCard(
              name: product.name,
              price: AppFormat.money(product.sellPrice),
              qty: "${product.stock} dona",
              imageUrl: product.imageUrl ?? '',
              onTap: () => context.push(
                PlatformRoutes.productDetails.route,
                extra: product,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: AppColors.sage.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            "Do'koningiz hozircha bo'sh!",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.forestDark,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            child: Text(
              "Mahsulotlarni qo'shing va savdoni boshlang. Har bir soniya — bu imkoniyat!",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.sage),
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push(PlatformRoutes.addNewProduct.route),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text(
              "Mahsulot qo'shish",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return BlocBuilder<ProductBloc, ProductState>(
      buildWhen: (p, c) => p.categories != c.categories || p.category != c.category,
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Kategoriyalar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.forestDark,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  final isSelected = state.category == category;
                  return _buildCategoryChip(category, isSelected);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryChip(String title, bool isSelected) {
    return GestureDetector(
      onTap: () =>
          context.read<ProductBloc>().add(FilterProductsByCategory(title)),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.mintLight,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.sage,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 15, bottom: 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Ombor',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.white,
              size: 28,
            ),
            onPressed: () => context.push(PlatformRoutes.addNewProduct.route),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.mintLight),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) =>
              context.read<ProductBloc>().add(SearchProducts(value)),
          decoration: const InputDecoration(
            icon: Icon(Icons.search, color: AppColors.sage),
            hintText: 'Mahsulot qidirish',
            hintStyle: TextStyle(color: AppColors.sage),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildListHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Text(
            'Barcha mahsulotlar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.forestDark,
            ),
          ),
        ],
      ),
    );
  }
}
