import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_bloc.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_event.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_state.dart';
import 'package:ocam_pos/presentation/inventory/widgets/edit_input_field.dart';

void showEditProductData(BuildContext context, ProductModel product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    // Sheet ProductBloc'ga muhtoj — main.dart'da global ta'minlangan nusxani
    // shu yerga ham uzatamiz, aks holda showModalBottomSheet yangi route
    // daraxti ochib, ota context'dagi provider'larni ko'ra olmaydi.
    builder: (_) => BlocProvider.value(
      value: context.read<ProductBloc>(),
      child: EditProductSheet(product: product),
    ),
  );
}

class EditProductSheet extends StatefulWidget {
  final ProductModel product;

  const EditProductSheet({super.key, required this.product});

  @override
  State<EditProductSheet> createState() => _EditProductSheetState();
}

class _EditProductSheetState extends State<EditProductSheet> {
  late final barcodeController = TextEditingController(
    text: widget.product.barcode,
  );
  late final nameController = TextEditingController(text: widget.product.name);
  late final qtyController = TextEditingController(
    text: widget.product.stock.toString(),
  );
  late final salePriceController = TextEditingController(
    text: widget.product.sellPrice.toString(),
  );
  late final buyPriceController = TextEditingController(
    text: widget.product.buyPrice.toString(),
  );
  late final descriptionController = TextEditingController(
    text: widget.product.description ?? "",
  );

  static const _categories = [
    'Umumiy',
    'Ichimliklar',
    'Shirinliklar',
    'Oziq-ovqat',
    'Uy-ro\'zg\'or',
  ];

  late String _selectedCategory = _categories.contains(widget.product.category)
      ? widget.product.category!
      : _categories.first;

  bool _isSaving = false;

  @override
  void dispose() {
    barcodeController.dispose();
    nameController.dispose();
    qtyController.dispose();
    salePriceController.dispose();
    buyPriceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _updateProduct() {
    setState(() => _isSaving = true);

    context.read<ProductBloc>().add(
      UpdateProduct(
        widget.product.copyWith(
          name: nameController.text.trim(),
          barcode: barcodeController.text.trim(),
          stock: int.tryParse(qtyController.text) ?? widget.product.stock,
          sellPrice:
              double.tryParse(salePriceController.text) ??
              widget.product.sellPrice,
          buyPrice:
              double.tryParse(buyPriceController.text) ??
              widget.product.buyPrice,
          category: _selectedCategory,
          description: descriptionController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listenWhen: (previous, current) =>
          current.actionMessage != null || current.error != null,
      listener: (context, state) {
        if (state.error != null) {
          setState(() => _isSaving = false);
          AppSnackBar.error(context, state.error!);
        } else if (state.actionMessage != null) {
          AppSnackBar.success(context, state.actionMessage!);
          Navigator.pop(context);
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandleBar(),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Mahsulotni tahrirlash",
                  style: TextStyle(
                    color: AppColors.forestDark,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              EditInputField(
                label: "Shtrix-kod",
                controller: barcodeController,
                isBarcode: true,
              ),
              EditInputField(
                label: "Mahsulot nomi",
                controller: nameController,
              ),

              Row(
                children: [
                  Expanded(
                    child: EditInputField(
                      label: "Miqdor",
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _buildCategoryDropdown()),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: EditInputField(
                      label: "Sotish narxi",
                      controller: salePriceController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: EditInputField(
                      label: "Tannarx",
                      controller: buyPriceController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              EditInputField(
                label: "Tavsif",
                controller: descriptionController,
                maxLines: 3,
              ),

              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Kategoriya",
          style: TextStyle(color: AppColors.sage, fontSize: 13),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: _categories
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(c, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: (val) =>
              setState(() => _selectedCategory = val ?? _selectedCategory),
        ),
      ],
    );
  }

  Widget _buildHandleBar() => Container(
    width: 45,
    height: 5,
    margin: const EdgeInsets.only(bottom: 24),
    decoration: BoxDecoration(
      color: AppColors.mintMedium,
      borderRadius: BorderRadius.circular(10),
    ),
  );

  Widget _buildSaveButton() => SizedBox(
    width: double.infinity,
    height: 58,
    child: ElevatedButton(
      onPressed: _isSaving ? null : _updateProduct,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: _isSaving
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              "Saqlash",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    ),
  );
}
