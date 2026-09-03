import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/core/utils/receipt_printer.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/core/widgets/confirm_dialog.dart';
import 'package:ocam_pos/data/models/sale_model.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_bloc.dart';
import 'package:ocam_pos/presentation/sale/bloc/sale_bloc.dart';
import 'package:ocam_pos/presentation/sale/bloc/sale_event.dart';
import 'package:ocam_pos/presentation/sale/bloc/sale_state.dart';
import 'package:ocam_pos/presentation/sale/widgets/receipt_item_row.dart';

/// Savdo cheki.
///
/// [sale] berilsa — o'sha savdo ko'rsatiladi (mijoz xaridlari tarixi yoki
/// hisobotdagi ro'yxatdan ochilganda). Berilmasa — oxirgi yakunlangan savdo
/// (`SaleBloc.state.completedSale`), ya'ni to'lov tugagandan keyingi holat.
class ReceiptDetailScreen extends StatefulWidget {
  final SaleModel? sale;

  const ReceiptDetailScreen({super.key, this.sale});

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  /// Shu ekranda qaytarilgan bo'lsa — ro'yxatdan kelgan nusxa eski
  /// bo'lgani uchun holatni shu yerda eslab qolamiz.
  bool _refundedHere = false;

  Future<void> _refund(BuildContext context, SaleModel sale) async {
    final confirmed = await showConfirmDialog(
      context,
      title: "Savdoni qaytarish",
      message:
          "${AppFormat.money(sale.total)} lik savdo qaytarilsinmi? "
          "Mahsulotlar omborga qaytadi"
          "${sale.paymentMethod == 'cash' ? ", pul kassadan yechiladi" : ""}.",
      confirmLabel: "Ha, qaytarish",
    );
    if (!confirmed || !context.mounted) return;

    context.read<SaleBloc>().add(RefundSaleEvent(sale.id));
  }

  @override
  Widget build(BuildContext context) {
    final sale = widget.sale ?? context.watch<SaleBloc>().state.completedSale;
    final isRefunded = sale != null && (sale.refunded || _refundedHere);
    final canRefund = sale != null && sale.id.isNotEmpty && !isRefunded;

    return BlocListener<SaleBloc, SaleState>(
      listenWhen: (previous, current) =>
          current.refundedSaleId != null || current.error != previous.error,
      listener: (context, state) {
        if (state.error != null) {
          AppSnackBar.error(context, state.error!);
          context.read<SaleBloc>().add(const SaleMessageCleared());
        } else if (state.refundedSaleId != null) {
          setState(() => _refundedHere = true);
          AppSnackBar.success(context, "Savdo qaytarildi");
        }
      },
      child: _buildScaffold(context, sale, isRefunded, canRefund),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    SaleModel? sale,
    bool isRefunded,
    bool canRefund,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
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
        title: Text(
          sale == null
              ? "Chek"
              : "Chek #${sale.id.length >= 6 ? sale.id.substring(0, 6) : sale.id}",
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (sale != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (value) {
                if (value == 'print') {
                  ReceiptPrinter.printReceipt(
                    sale.items,
                    sale.total,
                    sale: sale,
                    store: context.read<ProfileBloc>().state.user,
                  );
                } else if (value == 'refund') {
                  _refund(context, sale);
                }
              },
              itemBuilder: (context) => [
                _buildPopupItem('print', Icons.print_outlined, "Chop etish"),
                if (canRefund)
                  _buildPopupItem(
                    'refund',
                    Icons.undo_rounded,
                    "Savdoni qaytarish",
                    isDestructive: true,
                  ),
              ],
            ),
        ],
      ),
      body: sale == null
          ? const Center(
              child: Text(
                "Ko'rsatiladigan chek yo'q",
                style: TextStyle(color: AppColors.sage),
              ),
            )
          : _buildReceipt(sale, isRefunded),
    );
  }

  Widget _buildReceipt(SaleModel sale, bool isRefunded) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          if (isRefunded) _buildRefundedBanner(),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.mintLight),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const ReceiptItemRow(
                  name: "Mahsulot",
                  qty: "Soni",
                  price: "Narxi",
                  isHeader: true,
                ),
                const Divider(
                  indent: 20,
                  endIndent: 20,
                  color: AppColors.mintLight,
                ),
                ...sale.items.map(
                  (item) => ReceiptItemRow(
                    name: item.product.name,
                    qty: "x${item.quantity}",
                    price: AppFormat.money(item.subTotal),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    thickness: 1,
                    height: 40,
                    color: AppColors.mintLight,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppFormat.dateTime(sale.createdAt),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.forestDark,
                          fontSize: 14,
                        ),
                      ),
                      if (sale.customerName != null &&
                          sale.customerName!.isNotEmpty) ...[
                        const SizedBox(height: 15),
                        const Text(
                          "Mijoz",
                          style: TextStyle(
                            color: AppColors.sage,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sale.customerName!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.forestDark,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      if (sale.cashierName != null &&
                      sale.cashierName!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      "Kassir",
                      style: TextStyle(
                        color: AppColors.sage,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sale.cashierName!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.forestDark,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  if (sale.note.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          "Eslatma",
                          style: TextStyle(
                            color: AppColors.sage,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sale.note,
                          style: const TextStyle(
                            color: AppColors.forestDark,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    thickness: 1,
                    height: 40,
                    color: AppColors.mintLight,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Savdo yakunlandi",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.forestDark,
                          ),
                          children: [
                            const TextSpan(text: "JAMI "),
                            TextSpan(
                              text: AppFormat.money(sale.total),
                              style: const TextStyle(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "To'lov turi: ${sale.paymentMethod == 'card' ? 'Plastik karta' : 'Naqd pul'}",
                        style: const TextStyle(
                          color: AppColors.sage,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefundedBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.undo_rounded, color: AppColors.error),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Bu savdo qaytarilgan: mahsulotlar omborga qaytarilgan va "
              "hisobotda hisobga olinmaydi.",
              style: TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String value,
    IconData icon,
    String text, {
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
}
