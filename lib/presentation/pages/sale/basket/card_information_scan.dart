import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/presentation/widgets/basket_widget/payment_option_card.dart';

void showPaymentMethodBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const PaymentMethodSheet(),
  );
}

class PaymentMethodSheet extends StatefulWidget {
  const PaymentMethodSheet({super.key});

  @override
  State<PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<PaymentMethodSheet> {
  String _selectedMethod = 'Credit Card';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 45,
            height: 5,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.mintMedium,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Payment Methods",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.forestDark,
              ),
            ),
          ),
          const SizedBox(height: 20),
          PaymentOptionCard(
            id: 'Credit Card',
            title: 'Credit Card',
            subtitle: 'Visa - Mastercard - Meeza',
            icon: Icons.credit_card_outlined,
            isSelected: _selectedMethod == 'Credit Card',
            onTap: () => setState(() => _selectedMethod = 'Credit Card'),
          ),
          PaymentOptionCard(
            id: 'Cash',
            title: 'Cash',
            subtitle: 'Pay with physical money',
            icon: Icons.account_balance_wallet_outlined,
            isSelected: _selectedMethod == 'Cash',
            onTap: () => setState(() => _selectedMethod = 'Cash'),
          ),
          PaymentOptionCard(
            id: 'Scan & Pay',
            title: 'Scan & Pay',
            subtitle: 'Digital Wallet : Vodafone Cash',
            icon: Icons.qr_code_scanner,
            isSelected: _selectedMethod == 'Scan & Pay',
            onTap: () => setState(() => _selectedMethod = 'Scan & Pay'),
          ),
          PaymentOptionCard(
            id: 'Pay by link',
            title: 'Pay by link',
            subtitle: 'For VIP Customers Only',
            icon: Icons.link,
            isSelected: _selectedMethod == 'Pay by link',
            onTap: () => setState(() => _selectedMethod = 'Pay by link'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Select Payment Method",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
