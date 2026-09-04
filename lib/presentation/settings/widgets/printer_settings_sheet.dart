import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/receipt_paper.dart';
import 'package:ocam_pos/core/utils/receipt_printer.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/data/models/cart_item_model.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_bloc.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_event.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_state.dart';
import 'package:ocam_pos/presentation/settings/widgets/settings_sheet_frame.dart';

/// Printer sozlamalari: chek qog'ozi o'lchami va sinov cheki.
///
/// Ilgari bu sozlama faqat "Tez orada" xabarini chiqarardi, holbuki chek
/// har doim 80 mm lentaga qattiq bog'lab qo'yilgan edi — 58 mm printerli
/// do'konda chek qiyshiq chiqardi.
void showPrinterSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => BlocProvider.value(
      value: context.read<ProfileBloc>(),
      child: const _PrinterSettingsSheet(),
    ),
  );
}

class _PrinterSettingsSheet extends StatelessWidget {
  const _PrinterSettingsSheet();

  /// Sinov cheki — printer ulanganini va qog'oz o'lchami to'g'riligini
  /// haqiqiy savdo qilmasdan tekshirish uchun.
  static final _sampleItems = [
    const CartItem(
      product: ProductModel(
        id: 'namuna',
        name: 'Sinov mahsuloti',
        barcode: '0000000000000',
        buyPrice: 8000,
        sellPrice: 12000,
        stock: 1,
      ),
      quantity: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final user = state.user;
        final selected = user?.receiptPaper ?? ReceiptPaper.roll80;

        return SettingsSheetFrame(
          title: "Printer",
          subtitle: "Chek qaysi qog'ozga chiqarilishini tanlang",
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final paper in ReceiptPaper.values)
                SettingsChoiceTile(
                  title: paper.label,
                  subtitle: paper.description,
                  selected: paper == selected,
                  onTap: () {
                    if (paper != selected) {
                      context.read<ProfileBloc>().add(
                        UpdateStoreInfo(receiptPaper: paper),
                      );
                    }
                    Navigator.pop(context);
                  },
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await ReceiptPrinter.printReceipt(
                      _sampleItems,
                      24000,
                      store: user,
                    );
                  } catch (error) {
                    if (context.mounted) {
                      AppSnackBar.error(context, "Chek chiqmadi: $error");
                    }
                  }
                },
                icon: const Icon(Icons.print_outlined),
                label: const Text("Sinov cheki chiqarish"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
