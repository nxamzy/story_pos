import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/core/utils/validators.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_bloc.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_event.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_state.dart';
import 'package:ocam_pos/presentation/sale/pages/scanner_page.dart';
import 'package:ocam_pos/presentation/sale/widgets/quick_add_field.dart';

void showQuickAddProductSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    // Sheet o'zining BlocProvider'iga muhtoj emas — ProductBloc ildizda
    // (main.dart) global ta'minlangan, shu bir xil nusxa bu yerda ham ishlaydi.
    builder: (context) => const QuickAddProductSheet(),
  );
}

class QuickAddProductSheet extends StatefulWidget {
  const QuickAddProductSheet({super.key});

  @override
  State<QuickAddProductSheet> createState() => _QuickAddProductSheetState();
}

class _QuickAddProductSheetState extends State<QuickAddProductSheet> {
  final _formKey = GlobalKey<FormState>();
  final barcodeController = TextEditingController();
  final nameController = TextEditingController();
  final qtyController = TextEditingController();
  final salePriceController = TextEditingController();
  final purchasePriceController = TextEditingController();
  final categoryController = TextEditingController(text: "Umumiy");
  final descController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    barcodeController.dispose();
    nameController.dispose();
    qtyController.dispose();
    salePriceController.dispose();
    purchasePriceController.dispose();
    categoryController.dispose();
    descController.dispose();
    super.dispose();
  }

  void _onSaveProduct() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final newProduct = ProductModel(
      id: '',
      name: nameController.text.trim(),
      barcode: barcodeController.text.trim(),
      buyPrice: double.tryParse(purchasePriceController.text) ?? 0,
      sellPrice: double.tryParse(salePriceController.text) ?? 0,
      stock: int.tryParse(qtyController.text) ?? 0,
      category: categoryController.text.trim().isEmpty
          ? "Umumiy"
          : categoryController.text.trim(),
      description: descController.text.trim(),
    );

    context.read<ProductBloc>().add(AddProduct(newProduct));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocListener<ProductBloc, ProductState>(
      // `actionMessage` faqat ushbu bloc orqali bajarilgan amal (qo'shish,
      // yangilash, o'chirish) muvaffaqiyatli tugaganda o'rnatiladi — shu
      // sababli boshqa ekrandagi ro'yxat yangilanishidan farqlanadi.
      listenWhen: (previous, current) =>
          current.actionMessage != null || current.error != null,
      listener: (context, state) {
        if (state.error != null) {
          setState(() => _isSaving = false);
          AppSnackBar.error(context, state.error!);
        } else if (state.actionMessage != null) {
          Navigator.pop(context);
        }
      },
      child: Container(
        height: screenHeight * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.mintMedium,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const Text(
                        "Tezkor mahsulot qo'shish",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.forestDark,
                        ),
                      ),
                      const SizedBox(height: 20),

                      QuickAddInputField(
                        label: "Shtrix-kod",
                        controller: barcodeController,
                        suffixIcon: Icons.qr_code_scanner,
                        onSuffixTap: () async {
                          final result = await openBarcodeScanner(context);
                          if (result != null && result.isNotEmpty) {
                            setState(() => barcodeController.text = result);
                            _fillFromExisting(result);
                          }
                        },
                      ),

                      QuickAddInputField(
                        label: "Mahsulot nomi",
                        controller: nameController,
                        showClear: true,
                        validator: (v) => Validators.required(v, "Nomi"),
                      ),
                      QuickAddInputField(
                        label: "Boshlang'ich miqdor",
                        controller: qtyController,
                        keyboardType: TextInputType.number,
                        validator: Validators.quantity,
                      ),
                      QuickAddInputField(
                        label: "Kategoriya",
                        controller: categoryController,
                      ),
                      QuickAddInputField(
                        label: "Sotish narxi",
                        controller: salePriceController,
                        keyboardType: TextInputType.number,
                        validator: Validators.price,
                      ),
                      QuickAddInputField(
                        label: "Tannarx",
                        controller: purchasePriceController,
                        keyboardType: TextInputType.number,
                        validator: Validators.price,
                      ),
                      QuickAddInputField(
                        label: "Tavsif",
                        controller: descController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _onSaveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Mahsulot qo'shish",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shtrix-kod bo'yicha allaqachon mavjud mahsulotni topsa, formani
  /// to'ldiradi — bir xil mahsulot ikki marta yaratilib qolmasligi uchun.
  void _fillFromExisting(String barcode) {
    final products = context.read<ProductBloc>().state.products;
    ProductModel? match;
    for (final p in products) {
      if (p.barcode == barcode) {
        match = p;
        break;
      }
    }
    if (match == null) return;

    setState(() {
      nameController.text = match!.name;
      salePriceController.text = AppFormat.editableNumber(match.sellPrice);
      purchasePriceController.text = AppFormat.editableNumber(match.buyPrice);
      qtyController.text = match.stock.toString();
      categoryController.text = match.category ?? "Umumiy";
    });
  }
}
