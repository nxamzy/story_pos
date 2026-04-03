import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'package:ocam_pos/logic/blocs/products/product_bloc.dart';
import 'package:ocam_pos/logic/blocs/products/product_event.dart';
import 'package:ocam_pos/logic/blocs/products/product_state.dart';
import 'package:ocam_pos/presentation/pages/sale/main_sale/scanner/scanner_page.dart';
import 'package:ocam_pos/presentation/widgets/sale_widget/main_sale/quick_add_field.dart';

void bottomsheetdfsdfa(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const QuickAddProductSheet(),
  );
}

class QuickAddProductSheet extends StatefulWidget {
  const QuickAddProductSheet({super.key});

  @override
  State<QuickAddProductSheet> createState() => _QuickAddProductSheetState();
}

class _QuickAddProductSheetState extends State<QuickAddProductSheet> {
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  @override
  void dispose() {
    barcodeController.dispose();
    nameController.dispose();
    qtyController.dispose();
    salePriceController.dispose();
    purchasePriceController.dispose();
    expiryController.dispose();
    descController.dispose();
    super.dispose();
  }

  void _onSaveProduct() {
    final name = nameController.text.trim();
    final salePrice = double.tryParse(salePriceController.text) ?? 0.0;
    final user = FirebaseAuth.instance.currentUser;

    if (name.isEmpty || salePrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ism va narxni kiriting!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (user == null) return;

    final newProduct = ProductModel(
      id: '',
      userId: user.uid,
      name: name,
      barcode: barcodeController.text.trim(),
      buyPrice: double.tryParse(purchasePriceController.text) ?? 0.0,
      sellPrice: salePrice,
      stock: int.tryParse(qtyController.text) ?? 0,
      category: "General",
    );

    context.read<ProductBloc>().add(AddProduct(newProduct));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductLoaded) {
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
                      "Quick Add Product",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.forestDark,
                      ),
                    ),
                    const SizedBox(height: 20),

                    QuickAddInputField(
                      label: "Barcode",
                      controller: barcodeController,
                      suffixIcon: Icons.qr_code_scanner,
                      onSuffixTap: () async {
                        final String? result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScannerPage(),
                          ),
                        );
                        if (result != null && result.isNotEmpty) {
                          setState(() => barcodeController.text = result);
                          _searchProduct(result);
                        }
                      },
                    ),

                    QuickAddInputField(
                      label: "Product Name",
                      controller: nameController,
                      showClear: true,
                    ),
                    QuickAddInputField(
                      label: "Initial Quantity",
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                    ),
                    _buildDropdownField("Category", "Beverages"),
                    QuickAddInputField(
                      label: "Sale Price",
                      controller: salePriceController,
                      keyboardType: TextInputType.number,
                    ),
                    QuickAddInputField(
                      label: "Purchase Price",
                      controller: purchasePriceController,
                      keyboardType: TextInputType.number,
                    ),
                    QuickAddInputField(
                      label: "Description",
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
                  onPressed: _onSaveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Add Product",
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
    );
  }

  void _searchProduct(String barcode) {
    final state = context.read<ProductBloc>().state;
    if (state is ProductLoaded) {
      try {
        final product = state.products.firstWhere((p) => p.barcode == barcode);
        setState(() {
          nameController.text = product.name;
          salePriceController.text = product.sellPrice.toString();
          purchasePriceController.text = product.buyPrice.toString();
          qtyController.text = product.stock.toString();
        });
      } catch (e) {
        debugPrint("Yangi mahsulot");
      }
    }
  }

  Widget _buildDropdownField(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.mintLight, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.sage),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Icon(Icons.keyboard_arrow_down, color: AppColors.sage),
        ],
      ),
    );
  }
}
