import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/presentation/widgets/inventory_widget/custom_text_field.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  final _barcodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _itemsInBoxController = TextEditingController(
    text: "1",
  ); // Karobka uchun default 1
  final _salePriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _descriptionController = TextEditingController();

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
    _tabController = TabController(length: 2, vsync: this);
    // Tab o'zgarganda UI yangilanishi uchun
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _barcodeController.dispose();
    _nameController.dispose();
    _qtyController.dispose();
    _itemsInBoxController.dispose();
    _salePriceController.dispose();
    _purchasePriceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      _showSnackBar("Iltimos, kategoriyani tanlang", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Foydalanuvchi aniqlanmadi!");

      // 🔥 MULTI-UNIT LOGIC:
      int enteredQty = int.tryParse(_qtyController.text) ?? 0;
      int perBox = int.tryParse(_itemsInBoxController.text) ?? 1;

      // Agar 'Karobka' tabi tanlangan bo'lsa (index 1), sonini ko'paytiramiz
      int finalStock = (_tabController.index == 1)
          ? (enteredQty * perBox)
          : enteredQty;

      final productData = {
        'userId': user.uid,
        'name': _nameController.text.trim(),
        'barcode': _barcodeController.text.trim(),
        'stock': finalStock, // Bazaga umumiy dona bo'lib kiradi
        'sellPrice': double.tryParse(_salePriceController.text) ?? 0.0,
        'buyPrice': double.tryParse(_purchasePriceController.text) ?? 0.0,
        'category': _selectedCategory,
        'unitType': _tabController.index == 0 ? 'Dona' : 'Karobka',
        'itemsPerBox': perBox,
        'description': _descriptionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrl': null,
      };

      await FirebaseFirestore.instance.collection('products').add(productData);
      _showSnackBar("Mahsulot muvaffaqiyatli qo'shildi!", Colors.green);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Xatolik: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Add New Product',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2_outlined), text: "Dona (Unit)"),
            Tab(icon: Icon(Icons.all_inbox_rounded), text: "Karobka (Box)"),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildFormCard(),
                  const SizedBox(height: 24),
                  _buildAddButton(),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.mintLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tabController.index == 0 ? "Single Unit Mode" : "Bulk Box Mode",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.forestDark,
            ),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: "Barcode",
            controller: _barcodeController,
            suffixIcon: Icons.qr_code_scanner_rounded,
          ),
          CustomTextField(
            label: "Product Name",
            controller: _nameController,
            hint: "e.g. Redbull",
          ),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: _tabController.index == 0
                      ? "Quantity (Dona)"
                      : "Box Count (Karobka)",
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                ),
              ),
              if (_tabController.index == 1) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    label: "Pcs in Box",
                    controller: _itemsInBoxController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ],
          ),

          _buildDropdownLabel("Category"),
          _buildCategoryDropdown(),

          CustomTextField(
            label: "Sale Price",
            controller: _salePriceController,
            keyboardType: TextInputType.number,
          ),
          CustomTextField(
            label: "Purchase Price",
            controller: _purchasePriceController,
            keyboardType: TextInputType.number,
          ),
          CustomTextField(
            label: "Description",
            controller: _descriptionController,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  // --- Dropdown metodlarini o'zgarishsiz qoldirdim ---
  Widget _buildDropdownLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      label,
      style: const TextStyle(
        color: AppColors.sage,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: _dropdownDecoration(),
      items: _categories
          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
          .toList(),
      onChanged: (val) => setState(() => _selectedCategory = val),
    );
  }

  InputDecoration _dropdownDecoration() => InputDecoration(
    filled: true,
    fillColor: AppColors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.mintLight),
    ),
  );

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          _isLoading ? "Saving..." : "Add Product",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
