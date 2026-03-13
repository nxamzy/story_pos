import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart'; // AppColors importi

class SupplierTab extends StatelessWidget {
  const SupplierTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Suppliers',
          style: TextStyle(
            color: AppColors.forestDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.primary),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list, color: AppColors.primary),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Vizual qism (Container bilan bezatilgan)
              _buildSupplierEmptyState(),
              const SizedBox(height: 32),

              // 2. Sarlavha va Tavsif
              const Text(
                'No Suppliers Yet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Keep track of your suppliers, their contact info, and order history in one place.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.sage,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),

      // Yangi yetkazib beruvchi qo'shish tugmasi
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add Supplier logic
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.add_business_rounded, color: Colors.white),
      ),
    );
  }

  // --- YORDAMCHI WIDGETLAR ---

  Widget _buildSupplierEmptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.local_shipping_outlined,
          size: 70,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
