import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/core/utils/receipt_printer.dart';
import 'package:ocam_pos/presentation/sale/bloc/sale_bloc.dart';
import 'package:ocam_pos/presentation/sale/bloc/sale_event.dart';
import 'package:ocam_pos/presentation/sale/bloc/sale_state.dart';
import 'package:ocam_pos/presentation/sale/widgets/basket_customer_sheet.dart';
import 'package:ocam_pos/presentation/sale/widgets/basket_item_card.dart';
import 'package:ocam_pos/presentation/sale/widgets/payment_method_sheet.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';

class BasketScreen extends StatelessWidget {
  const BasketScreen({super.key});

  String _paymentLabel(String id) => kPaymentMethods
      .firstWhere((m) => m.id == id, orElse: () => kPaymentMethods.first)
      .title;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SaleBloc, SaleState>(
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
              "Savat",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'print') {
                    await ReceiptPrinter.printReceipt(
                      state.cartItems,
                      state.totalAmount,
                    );
                  } else if (value == 'clear') {
                    context.read<SaleBloc>().add(const ClearCartEvent());
                  }
                },
                itemBuilder: (context) => [
                  _buildPopupItem('print', "Chop etish", Icons.print_outlined),
                  _buildPopupItem(
                    'clear',
                    "Tozalash",
                    Icons.delete_outline,
                    isDestructive: true,
                  ),
                ],
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
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) =>
                            CartItemCard(item: cartItems[index]),
                      ),
                    ),
                    _buildCheckoutSection(context, state),
                  ],
                ),
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
            Icons.shopping_basket_outlined,
            size: 72,
            color: AppColors.sage.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          const Text(
            "Savat bo'sh",
            style: TextStyle(
              color: AppColors.forestDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Text(
            "Jami mahsulotlar ($count)",
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

  Widget _buildCheckoutSection(BuildContext context, SaleState state) {
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
          _optionRow(
            Icons.person_add_alt,
            state.customer?.name ?? "Mijoz tanlash (ixtiyoriy)",
            () async {
              final selected = await showCustomerSheet(
                context,
                current: state.customer,
              );
              if (context.mounted) {
                context.read<SaleBloc>().add(SelectSaleCustomerEvent(selected));
              }
            },
          ),
          const Divider(height: 32, color: AppColors.mintLight),
          _optionRow(
            Icons.payment_outlined,
            _paymentLabel(state.paymentMethod),
            () async {
              final selected = await showPaymentMethodSheet(
                context,
                current: state.paymentMethod,
              );
              if (selected != null && context.mounted) {
                context.read<SaleBloc>().add(SelectPaymentMethodEvent(selected));
              }
            },
          ),
          const SizedBox(height: 24),
          _priceRow("Mahsulotlar", AppFormat.money(state.subTotal)),
          const SizedBox(height: 8),
          _priceRow("Soliq", AppFormat.money(state.tax), isPrimary: true),
          const Divider(height: 32, color: AppColors.mintLight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Jami",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestDark,
                ),
              ),
              Text(
                AppFormat.money(state.totalAmount),
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
                "To'lovga o'tish",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String value,
    String text,
    IconData icon, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: isDestructive ? AppColors.error : AppColors.forestDark,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isDestructive ? AppColors.error : AppColors.forestDark,
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
              overflow: TextOverflow.ellipsis,
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
