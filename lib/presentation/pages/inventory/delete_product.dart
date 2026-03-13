import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/data/models/product_model.dart';

// --- 🎯 1. CHAQIRUV FUNKSIYASI ---
void showDeleteProduct(BuildContext context, ProductModel product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DeleteProductSheet(product: product),
  );
}

class DeleteProductSheet extends StatefulWidget {
  final ProductModel product; // 🔥 O'chiriladigan mahsulot

  const DeleteProductSheet({super.key, required this.product});

  @override
  State<DeleteProductSheet> createState() => _DeleteProductSheetState();
}

class _DeleteProductSheetState extends State<DeleteProductSheet> {
  bool isChecked = false;
  bool _isLoading = false; // 🔥 Yuklanish holati

  // --- 🔥 BAZADAN O'CHIRISH FUNKSIYASI ---
  Future<void> _deleteProductFromFirestore() async {
    setState(() => _isLoading = true);

    try {
      // 1. Firestore'dan o'chirish
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .delete();

      if (mounted) {
        // 2. Muvaffaqiyatli xabar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${widget.product.name} muvaffaqiyatli o'chirildi!"),
            backgroundColor: Colors.redAccent,
          ),
        );

        // 3. Sheetni yopish
        Navigator.pop(context);

        // 4. Agar ProductDetails sahifasida bo'lsak, orqaga qaytish
        // (Chunki mahsulot endi yo'q)
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Xatolik: $e"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SafeArea(
        child: Stack(
          // Yuklanish indikatori uchun
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHandleBar(),
                const SizedBox(height: 24),

                // 🚨 O'chirish ikonkasi animatsiya bilan
                _buildAnimatedIcon(),
                const SizedBox(height: 24),

                // Sarlavha (Dinamik nom bilan)
                Text(
                  "Delete '${widget.product.name}'?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.forestDark,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "This action is permanent and cannot be reversed. This product will be removed from your inventory forever.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.sage,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // Tasdiqlash Checkboxi
                _buildCheckboxTile(),

                const SizedBox(height: 32),

                // O'chirish Tugmasi
                _buildDeleteButton(),

                const SizedBox(height: 12),

                // Bekor qilish tugmasi
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "No, keep it",
                    style: TextStyle(
                      color: AppColors.sage,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.redAccent),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.delete_forever_rounded,
        size: 54,
        color: Colors.redAccent,
      ),
    );
  }

  Widget _buildCheckboxTile() {
    return InkWell(
      onTap: () => setState(() => isChecked = !isChecked),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isChecked ? Colors.red.withOpacity(0.03) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isChecked
                ? Colors.redAccent.withOpacity(0.3)
                : AppColors.mintLight,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isChecked ? Colors.redAccent : Colors.transparent,
                border: Border.all(
                  color: isChecked ? Colors.redAccent : AppColors.mintMedium,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                "I understand, delete this product",
                style: TextStyle(
                  color: AppColors.forestDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: (isChecked && !_isLoading)
            ? _deleteProductFromFirestore
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.background,
          disabledForegroundColor: AppColors.mintMedium,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Text(
          "Yes, Delete Forever",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      width: 45,
      height: 5,
      decoration: BoxDecoration(
        color: AppColors.mintMedium.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
