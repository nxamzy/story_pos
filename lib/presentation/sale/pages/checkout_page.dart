import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ocam_pos/core/utils/app_config.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/core/utils/receipt_printer.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_bloc.dart';
import 'package:ocam_pos/presentation/sale/bloc/sale_bloc.dart';
import 'package:ocam_pos/presentation/sale/bloc/sale_event.dart';
import 'package:ocam_pos/presentation/sale/bloc/sale_state.dart';
import 'package:ocam_pos/presentation/sale/pages/payment_success_page.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/presentation/sale/widgets/checkout_card.dart';

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
  void dispose() {
    _amountPaidController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SaleBloc, SaleState>(
      listenWhen: (previous, current) =>
          current.completedSale != previous.completedSale ||
          current.error != previous.error,
      listener: (context, state) async {
        if (state.error != null) {
          AppSnackBar.error(context, state.error!);
          context.read<SaleBloc>().add(const SaleMessageCleared());
          return;
        }

        final sale = state.completedSale;
        if (sale != null) {
          if (_printReceipt) {
            await ReceiptPrinter.printReceipt(
              sale.items,
              sale.total,
              sale: sale,
              store: context.read<ProfileBloc>().state.user,
            );
          }
          if (context.mounted) {
            showSuccessSheet(context);
          }
        }
      },
      builder: (context, saleState) {
        final double totalAmount = saleState.totalAmount;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(context),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Sana"),
                _buildDateCard(),

                _buildSectionTitle("Savatdagi mahsulotlar"),
                _buildProductTable(saleState),

                _buildSectionTitle("QR orqali to'lash"),
                _buildQRCodeCard(totalAmount),

                _buildSectionTitle("To'lanadigan summa"),
                _buildAmountCard(totalAmount),

                _buildSectionTitle("Eslatma"),
                _buildNoteCard(),
                _buildPrintSwitch(),

                const SizedBox(height: 20),
                _buildCompleteButton(saleState),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompleteButton(SaleState state) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: state.isProcessing
            ? null
            : () {
                final paid =
                    double.tryParse(_amountPaidController.text) ?? 0.0;

                if (paid < state.totalAmount) {
                  AppSnackBar.error(context, "To'langan summa yetarli emas!");
                  return;
                }

                context.read<SaleBloc>().add(
                  CompleteSaleEvent(
                    amountPaid: paid,
                    note: _noteController.text.trim(),
                    date: _selectedDate,
                  ),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: state.isProcessing
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Savdoni yakunlash",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildProductTable(SaleState state) {
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
                    AppFormat.money(item.subTotal),
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
                child: PrettyQrView.data(
                  data: 'pay?am=$amount&cu=${AppConfig.currency}',
                ),
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
            Text(
              AppFormat.money(totalAmount),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
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
      "To'lov",
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
          "Chekni chop etish",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Switch.adaptive(
          value: _printReceipt,
          activeThumbColor: AppColors.primary,
          onChanged: (v) => setState(() => _printReceipt = v),
        ),
      ],
    ),
  );

  Future<void> _selectDate(BuildContext context) async {
    // Kelajakdagi sanaga savdo yozib bo'lmaydi — hisobot buziladi.
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }
}
