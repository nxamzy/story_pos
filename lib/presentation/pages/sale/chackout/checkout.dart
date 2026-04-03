import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ocam_pos/presentation/bloc/billing_bloc.dart';
import 'package:ocam_pos/presentation/pages/sale/chackout/payment_successfull_scan.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/presentation/widgets/sale_widget/chackout/checkout_card.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _amountPaidController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _printReceipt = true;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BillingBloc, BillingState>(
      listener: (context, state) {
        if (state.saleSuccess) {
          showSuccessSheet(context, state.totalAmount);
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }

        if (!state.isLoading &&
            state.cartItems.isEmpty &&
            state.error == null) {
          print("Sotuv muvaffaqiyatli yakunlandi!");
        }
      },
      builder: (context, billingState) {
        final double totalAmount = billingState.totalAmount;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(context),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Invoice Date"),
                _buildDateCard(),

                _buildSectionTitle("Cart Items"),
                _buildProductTable(billingState),

                _buildSectionTitle("Scan to Pay"),
                _buildQRCodeCard(totalAmount),

                _buildSectionTitle("Amount to Pay"),
                _buildAmountCard(totalAmount),

                _buildSectionTitle("Note"),
                _buildNoteCard(),
                _buildPrintSwitch(),

                const SizedBox(height: 20),
                _buildCompleteButton(billingState),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompleteButton(BillingState state) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: state.isLoading
            ? null
            : () {
                final paid = double.tryParse(_amountPaidController.text) ?? 0.0;

                if (paid < state.totalAmount) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("To'langan summa yetarli emas!"),
                    ),
                  );
                  return;
                }

                context.read<BillingBloc>().add(
                  CompleteSaleEvent(
                    amountPaid: paid,
                    printReceipt: _printReceipt,
                  ),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: state.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Complete Sale",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildProductTable(BillingState state) {
    return CheckoutCard(
      child: Table(
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade200),
        ),
        children: [
          ...state.cartItems.map(
            (item) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text("${item.quantity} x ${item.product.name}"),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    "${(item.quantity * item.product.sellPrice).toStringAsFixed(2)} EGP",
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeCard(double amount) {
    return CheckoutCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              const Text(
                "Mijoz skanerlashi uchun",
                style: TextStyle(color: AppColors.sage, fontSize: 12),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 150,
                height: 150,
                child: PrettyQrView.data(data: 'pay?am=$amount&cu=EGP'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard(double totalAmount) {
    return CheckoutCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  totalAmount.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "EGP",
                  style: TextStyle(
                    color: AppColors.sage,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountPaidController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "To'langan summa",
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) => AppBar(
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
      "Checkout",
      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
    ),
  );

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 20, left: 4),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.sage,
      ),
    ),
  );

  Widget _buildDateCard() => CheckoutCard(
    onTap: () => _selectDate(context),
    child: ListTile(
      leading: const Icon(Icons.calendar_month, color: AppColors.primary),
      title: Text(DateFormat('EEEE dd/MM/yyyy').format(_selectedDate)),
      trailing: const Icon(Icons.keyboard_arrow_down, color: AppColors.sage),
    ),
  );

  Widget _buildNoteCard() => CheckoutCard(
    child: TextField(
      controller: _noteController,
      maxLines: 2,
      decoration: const InputDecoration(
        hintText: "Eslatma...",
        contentPadding: EdgeInsets.all(16),
        border: InputBorder.none,
      ),
    ),
  );

  Widget _buildPrintSwitch() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Print Receipt",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Switch.adaptive(
          value: _printReceipt,
          activeColor: AppColors.primary,
          onChanged: (v) => setState(() => _printReceipt = v),
        ),
      ],
    ),
  );

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }
}
