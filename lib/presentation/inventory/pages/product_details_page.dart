import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_bloc.dart';
import 'package:ocam_pos/presentation/inventory/widgets/product_info_sheet.dart';
import 'package:ocam_pos/presentation/inventory/widgets/delete_product_sheet.dart';
import 'package:ocam_pos/presentation/inventory/widgets/detail_row.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    // ProductBloc'dagi joriy ro'yxatdan tirik nusxasini olamiz — aks holda
    // "Tahrirlash"dan keyin bu sahifa eski (widget.product) qiymatlarni
    // ko'rsatishda davom etadi, chunki Navigator.pop qaytargan sahifa
    // qayta build bo'lmaydi.
    final product = context
        .watch<ProductBloc>()
        .state
        .products
        .firstWhere(
          (p) => p.id == widget.product.id,
          orElse: () => widget.product,
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Mahsulot tafsilotlari",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [_buildPopupMenu(context, product), const SizedBox(width: 8)],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildProductImage(product),
            const SizedBox(height: 32),
            _buildInfoCard(context, product),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, ProductModel product) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert, color: AppColors.primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              SizedBox(width: 10),
              Text("O'chirish", style: TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 1) showDeleteProduct(context, product);
      },
    );
  }

  Widget _buildProductImage(ProductModel product) {
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.mintLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestDark.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
            ? Image.network(
                product.imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholderIcon(),
              )
            : _buildPlaceholderIcon(),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return const Icon(Icons.fastfood_rounded, size: 60, color: AppColors.sage);
  }

  Widget _buildInfoCard(BuildContext context, ProductModel product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.mintLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Mahsulot ma'lumoti",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestDark,
                ),
              ),
              TextButton.icon(
                onPressed: () => showEditProductData(context, product),
                icon: const Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: const Text(
                  "Tahrirlash",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DetailRow(label: "Nomi", value: product.name),
          DetailRow(label: "Shtrix-kod", value: product.barcode),
          DetailRow(label: "Miqdor", value: "${product.stock} dona"),
          DetailRow(
            label: "Kategoriya",
            value: product.category ?? "Kategoriyasiz",
            isCategory: true,
          ),
          DetailRow(label: "Sotish narxi", value: AppFormat.money(product.sellPrice)),
          DetailRow(label: "Tannarx", value: AppFormat.money(product.buyPrice)),
          DetailRow(
            label: "Tavsif",
            value: product.description?.isNotEmpty == true
                ? product.description!
                : "Tavsif yo'q",
          ),
        ],
      ),
    );
  }
}
