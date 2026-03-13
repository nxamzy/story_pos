import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'package:ocam_pos/presentation/pages/inventory/card_information_inventory.dart';
import 'package:ocam_pos/presentation/pages/inventory/delete_product.dart';
import 'package:ocam_pos/presentation/widgets/inventory_widget/detail_row.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  Widget build(BuildContext context) {
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
          'Product Details',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [_buildPopupMenu(context), const SizedBox(width: 8)],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildProductImage(),
            const SizedBox(height: 32),
            _buildInfoCard(context, widget.product),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
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
              Text("Delete Product", style: TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 1) showDeleteProduct(context, widget.product);
      },
    );
  }

  Widget _buildProductImage() {
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.mintLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestDark.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child:
            (widget.product.imageUrl != null &&
                widget.product.imageUrl!.isNotEmpty)
            ? Image.network(
                widget
                    .product
                    .imageUrl!, // 🔥 Hardcoded URL o'rniga modeldan keladi
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholderIcon(),
              )
            : _buildPlaceholderIcon(), // Rasm bo'lmasa icon chiqadi
      ),
    );
  }

  // Placeholder uchun alohida kichik metod
  Widget _buildPlaceholderIcon() {
    return const Icon(Icons.fastfood_rounded, size: 60, color: AppColors.sage);
  }

  Widget _buildInfoCard(BuildContext context, ProductModel product) {
    // 🔥 'product' qo'shildi
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
                "Product Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestDark,
                ),
              ),
              TextButton.icon(
                // 🔥 ENDI BU ISHLAYDI! Joriy mahsulotni uzatamiz
                onPressed: () => showEditProductData(context, product),
                icon: const Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: const Text(
                  "Edit",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 🎯 Ma'lumotlarni modeldan olib chiqamiz:
          DetailRow(label: "Name", value: product.name),
          DetailRow(label: "Barcode", value: product.barcode),
          DetailRow(label: "Quantity", value: "${product.stock} pcs"),
          DetailRow(
            label: "Category",
            value: product.category ?? "No Category",
            isCategory: true,
          ),
          DetailRow(label: "Sale Price", value: "${product.sellPrice} EGP"),
          DetailRow(label: "Purchase Price", value: "${product.buyPrice} EGP"),
          DetailRow(
            label: "Description",
            value:
                product.description ??
                "No description", // 🔥 Modelda tuzatganimiz ishladi!
            isArabic: false,
          ),
          // Agar expiration date modelda bo'lsa:
          // DetailRow(label: "Expiration Date", value: product.expiryDate ?? "N/A"),
        ],
      ),
    );
  }
}
