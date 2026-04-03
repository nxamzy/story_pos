import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/printer_helper.dart';
import 'package:ocam_pos/presentation/bloc/billing_bloc.dart';
import 'package:ocam_pos/presentation/pages/sale/basket/cart_item_card.dart';
import 'package:ocam_pos/routes/platform_routes.dart';

class BasketScreen extends StatefulWidget {
  const BasketScreen({super.key});

  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillingBloc, BillingState>(
      builder: (context, state) {
        final cartItems = state.cartItems;

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
              "Basket",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              BlocBuilder<BillingBloc, BillingState>(
                builder: (context, state) {
                  return PopupMenuButton<String>(
                    onSelected: (String value) async {
                      print("Tanlangan qiymat: $value");

                      if (value == 'Print') {
                        print("Print funksiyasi ishga tushdi!");
                        await ReceiptPrinter.printReceipt(
                          state.cartItems,
                          state.totalAmount,
                        );
                      } else if (value == 'Delete') {
                        context.read<BillingBloc>().add(ClearCartEvent());
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      _buildPopupItem('Print', Icons.print_outlined),
                      _buildPopupItem(
                        'Delete',
                        Icons.delete_outline,
                        isDestructive: true,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          body: cartItems.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    _buildHeader(cartItems.length),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: cartItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) =>
                            CartItemCard(item: cartItems[index]),
                      ),
                    ),
                    _buildCheckoutSection(state),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "Savat bo'sh",
        style: TextStyle(color: AppColors.sage, fontSize: 16),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Text(
            "Total Products ($count)",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.sage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(BillingState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _optionRow(Icons.person_add_alt, "Select Customer (optional)", () {}),
          const Divider(height: 32, color: AppColors.mintLight),
          _optionRow(Icons.payment_outlined, "Select Payment Method", () {}),
          const SizedBox(height: 24),
          _priceRow("Subtotal", "${state.totalAmount.toStringAsFixed(2)} EGP"),
          const SizedBox(height: 8),
          _priceRow("Tax (0%)", "0.00 EGP", isPrimary: true),
          const Divider(height: 32, color: AppColors.mintLight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestDark,
                ),
              ),
              Text(
                "${state.totalAmount.toStringAsFixed(2)} EGP",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: state.cartItems.isEmpty
                  ? null
                  : () => context.push(PlatformRoutes.checkoutPage.route),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Checkout",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String text,
    IconData icon, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem(
      value: text,
      child: Row(
        children: [
          Icon(
            icon,
            color: isDestructive ? Colors.red : AppColors.forestDark,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isDestructive ? Colors.red : AppColors.forestDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionRow(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.forestDark,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.sage),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isPrimary = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.sage,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isPrimary ? AppColors.primary : AppColors.forestDark,
          ),
        ),
      ],
    );
  }
}
