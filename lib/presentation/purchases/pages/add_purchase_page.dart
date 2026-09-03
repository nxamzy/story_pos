import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/core/widgets/text_input_dialog.dart';
import 'package:ocam_pos/data/models/purchase_model.dart';
import 'package:ocam_pos/data/models/supplier_model.dart';
import 'package:ocam_pos/presentation/cashdrawer/bloc/cash_bloc.dart';
import 'package:ocam_pos/presentation/cashdrawer/bloc/cash_event.dart';
import 'package:ocam_pos/presentation/cashdrawer/bloc/cash_state.dart';
import 'package:ocam_pos/presentation/purchases/bloc/purchase_bloc.dart';
import 'package:ocam_pos/presentation/purchases/bloc/purchase_event.dart';
import 'package:ocam_pos/presentation/purchases/bloc/purchase_state.dart';
import 'package:ocam_pos/presentation/purchases/widgets/product_picker_sheet.dart';
import 'package:ocam_pos/presentation/supplier/bloc/supplier_bloc.dart';
import 'package:ocam_pos/presentation/supplier/bloc/supplier_event.dart';
import 'package:ocam_pos/presentation/supplier/bloc/supplier_state.dart';

/// Yangi xarid: ta'minotchi tanlanadi, mahsulotlar miqdori va tannarxi
/// bilan qo'shiladi, saqlanganda ombor to'ldiriladi.
class AddPurchasePage extends StatefulWidget {
  const AddPurchasePage({super.key});

  @override
  State<AddPurchasePage> createState() => _AddPurchasePageState();
}

class _AddPurchasePageState extends State<AddPurchasePage> {
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SupplierBloc>().add(const LoadSuppliers());
    context.read<CashBloc>().add(const LoadCashDrawer());
    // Sahifa har ochilganda toza qoralamadan boshlanadi.
    context.read<PurchaseBloc>().add(const ClearPurchaseDraft());
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    final product = await showProductPickerSheet(context);
    if (product == null || !mounted) return;
    context.read<PurchaseBloc>().add(AddPurchaseItem(product));
  }

  Future<void> _editPrice(PurchaseItem item) async {
    final value = await showTextInputDialog(
      context,
      title: "${item.name} — tannarx",
      initialValue: AppFormat.editableNumber(item.buyPrice),
      hint: "Bir dona uchun narx",
      keyboardType: TextInputType.number,
    );
    if (value == null || !mounted) return;

    context.read<PurchaseBloc>().add(
      UpdatePurchaseItem(item.productId, buyPrice: AppFormat.parseAmount(value)),
    );
  }

  Future<void> _editQuantity(PurchaseItem item) async {
    final value = await showTextInputDialog(
      context,
      title: "${item.name} — miqdor",
      initialValue: item.quantity.toString(),
      hint: "Nechta dona keldi",
      keyboardType: TextInputType.number,
    );
    if (value == null || !mounted) return;

    final quantity = int.tryParse(value.trim());
    if (quantity == null) return;

    context.read<PurchaseBloc>().add(
      UpdatePurchaseItem(item.productId, quantity: quantity),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PurchaseBloc, PurchaseState>(
      listenWhen: (previous, current) =>
          current.savedPurchaseId != null || current.error != previous.error,
      listener: (context, state) {
        if (state.error != null) {
          AppSnackBar.error(context, state.error!);
          context.read<PurchaseBloc>().add(const PurchaseMessageCleared());
        } else if (state.savedPurchaseId != null) {
          AppSnackBar.success(
            context,
            state.actionMessage ?? "Xarid saqlandi",
          );
          context.pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            title: const Text(
              "Yangi xarid",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSupplierPicker(state),
                const SizedBox(height: 20),
                _buildItems(state),
                const SizedBox(height: 20),
                _buildNote(),
                const SizedBox(height: 12),
                _buildPaymentSwitch(state),
                const SizedBox(height: 20),
                _buildTotal(state),
                const SizedBox(height: 20),
                _buildSaveButton(state),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSupplierPicker(PurchaseState state) {
    return BlocBuilder<SupplierBloc, SupplierState>(
      builder: (context, supplierState) {
        return _Card(
          title: "Ta'minotchi",
          child: DropdownButtonFormField<String>(
            initialValue: state.supplier?.id,
            isExpanded: true,
            hint: const Text("Ta'minotchini tanlang"),
            decoration: const InputDecoration(filled: true),
            items: supplierState.suppliers
                .map(
                  (supplier) => DropdownMenuItem(
                    value: supplier.id,
                    child: Text(
                      supplier.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              SupplierModel? match;
              for (final supplier in supplierState.suppliers) {
                if (supplier.id == value) {
                  match = supplier;
                  break;
                }
              }
              context.read<PurchaseBloc>().add(SelectPurchaseSupplier(match));
            },
          ),
        );
      },
    );
  }

  Widget _buildItems(PurchaseState state) {
    return _Card(
      title: "Mahsulotlar",
      trailing: TextButton.icon(
        onPressed: _addProduct,
        icon: const Icon(Icons.add, size: 18),
        label: const Text("Qo'shish"),
      ),
      child: state.draftItems.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "Hali mahsulot qo'shilmagan",
                style: TextStyle(color: AppColors.sage),
              ),
            )
          : Column(
              children: [
                for (final item in state.draftItems)
                  _PurchaseItemTile(
                    item: item,
                    onQuantityTap: () => _editQuantity(item),
                    onPriceTap: () => _editPrice(item),
                    onRemove: () => context.read<PurchaseBloc>().add(
                      RemovePurchaseItem(item.productId),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildNote() {
    return _Card(
      title: "Eslatma (ixtiyoriy)",
      child: TextField(
        controller: _noteController,
        maxLines: 2,
        decoration: const InputDecoration(
          hintText: "masalan: hujjat raqami",
          filled: true,
        ),
      ),
    );
  }

  Widget _buildPaymentSwitch(PurchaseState state) {
    return BlocBuilder<CashBloc, CashState>(
      builder: (context, cashState) {
        return _Card(
          title: "To'lov",
          child: SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: state.paidFromDrawer,
            activeThumbColor: AppColors.primary,
            onChanged: (value) => context.read<PurchaseBloc>().add(
              SetPurchasePaidFromDrawer(value),
            ),
            title: const Text(
              "Kassadan to'landi",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              state.paidFromDrawer
                  ? "Kassadan yechiladi (mavjud: ${AppFormat.money(cashState.balance)})"
                  : "Qarzga olindi — kassa balansi o'zgarmaydi",
              style: const TextStyle(fontSize: 12, color: AppColors.sage),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotal(PurchaseState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Jami (${state.draftQuantity} dona)",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.forestDark,
            ),
          ),
          Text(
            AppFormat.money(state.draftTotal),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(PurchaseState state) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (!state.canSubmit || state.isSaving)
            ? null
            : () => context.read<PurchaseBloc>().add(
                SubmitPurchase(note: _noteController.text.trim()),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: state.isSaving
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Omborga kiritish",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _Card({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mintLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestDark,
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PurchaseItemTile extends StatelessWidget {
  final PurchaseItem item;
  final VoidCallback onQuantityTap;
  final VoidCallback onPriceTap;
  final VoidCallback onRemove;

  const _PurchaseItemTile({
    required this.item,
    required this.onQuantityTap,
    required this.onPriceTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.mintLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.forestDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                AppFormat.money(item.subTotal),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.sage,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _EditableChip(
                  label: "Miqdor",
                  value: "${item.quantity} dona",
                  onTap: onQuantityTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _EditableChip(
                  label: "Tannarx",
                  value: AppFormat.money(item.buyPrice),
                  onTap: onPriceTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditableChip extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _EditableChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.mintLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppColors.sage, fontSize: 11),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.forestDark,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.edit, size: 14, color: AppColors.mintMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
