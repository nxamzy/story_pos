import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart'; // AppColors tizimi

class SaleTab extends StatelessWidget {
  const SaleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Sale',
          style: TextStyle(
            color: AppColors.forestDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.history, color: AppColors.primary),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Skaner Vizual qismi
              _buildScannerPlaceholder(),
              const SizedBox(height: 40),

              // 2. Matnlar
              const Text(
                'Ready to scan!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Scan the product barcode to add it to the cart or add manually.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.sage,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // 3. Qo'lda qo'shish tugmasi
              _buildManualAddButton(),
            ],
          ),
        ),
      ),

      // Markaziy Skaner Tugmasi (FloatingActionButton)
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          // QR/Barcode Scanner logic
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(
          Icons.qr_code_scanner_rounded,
          size: 40,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // --- YORDAMCHI WIDGETLAR ---

  Widget _buildScannerPlaceholder() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Orqa fondagi animatsion doiralar uchun (Decoration)
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.05),
          ),
        ),
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.1),
          ),
        ),
        // Asosiy Ikonka
        const Icon(
          Icons.document_scanner_outlined,
          size: 100,
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildManualAddButton() {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.keyboard_outlined),
      label: const Text("Enter Code Manually"),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
