import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'package:ocam_pos/presentation/widgets/inventory_widget/edit_input_field.dart';

void showEditProductData(BuildContext context, ProductModel product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => EditProductSheet(product: product),
  );
}

class EditProductSheet extends StatefulWidget {
  final ProductModel product;

  const EditProductSheet({super.key, required this.product});

  @override
  State<EditProductSheet> createState() => _EditProductSheetState();
}

class _EditProductSheetState extends State<EditProductSheet> {
  late TextEditingController barcodeController;
  late TextEditingController nameController;
  late TextEditingController qtyController;
  late TextEditingController salePriceController;
  late TextEditingController buyPriceController;
  late TextEditingController descriptionController;

  String? _selectedCategory;
  bool _isLoading = false;

  final List<String> _categories = [
    'General',
    'Beverages',
    'Candy',
    'Packaged Food',
    'Home',
  ];

  @override
  void initState() {
    super.initState();
    String initialCat = widget.product.category ?? 'General';
    if (!_categories.contains(initialCat)) {
      _selectedCategory = _categories.first;
    } else {
      _selectedCategory = initialCat;
    }
    barcodeController = TextEditingController(text: widget.product.barcode);
    nameController = TextEditingController(text: widget.product.name);
    qtyController = TextEditingController(
      text: widget.product.stock.toString(),
    );
    salePriceController = TextEditingController(
      text: widget.product.sellPrice.toString(),
    );
    buyPriceController = TextEditingController(
      text: widget.product.buyPrice.toString(),
    );
    descriptionController = TextEditingController(
      text: widget.product.description ?? "",
    );
    _selectedCategory = widget.product.category;
  }

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

  Future<void> _updateProduct() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .update({
            'name': nameController.text.trim(),
            'barcode': barcodeController.text.trim(),
            'stock': int.tryParse(qtyController.text) ?? 0,
            'sellPrice': double.tryParse(salePriceController.text) ?? 0.0,
            'buyPrice': double.tryParse(buyPriceController.text) ?? 0.0,
            'category': _selectedCategory,
            'description': descriptionController.text.trim(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Muvaffaqiyatli yangilandi!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Xatolik: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHandleBar(),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Edit Product Data",
                    style: TextStyle(
                      color: AppColors.forestDark,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                EditInputField(
                  label: "Barcode",
                  controller: barcodeController,
                  isBarcode: true,
                ),
                EditInputField(
                  label: "Product Name",
                  controller: nameController,
                ),

                Row(
                  children: [
                    Expanded(
                      child: EditInputField(
                        label: "Quantity",
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
                        label: "Sale Price",
                        controller: salePriceController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: EditInputField(
                        label: "Purchase Price",
                        controller: buyPriceController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                EditInputField(
                  label: "Description",
                  controller: descriptionController,
                  maxLines: 3,
                ),

                const SizedBox(height: 24),
                _buildSaveButton(),
              ],
            ),
          ),
          if (_isLoading)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Category",
          style: TextStyle(color: AppColors.sage, fontSize: 13),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _categories.contains(_selectedCategory)
              ? _selectedCategory
              : _categories.first,
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
          onChanged: (val) => setState(() => _selectedCategory = val),
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
      onPressed: _isLoading ? null : _updateProduct,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: Text(
        _isLoading ? "Updating..." : "Save Changes",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );
}
