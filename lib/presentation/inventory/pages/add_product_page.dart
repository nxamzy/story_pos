import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/validators.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_bloc.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_event.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_state.dart';
import 'package:ocam_pos/presentation/inventory/widgets/inventory_text_field.dart';

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
  final _itemsInBoxController = TextEditingController(text: "1");
  final _salePriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  bool _isSaving = false;

  final List<String> _categories = [
    'Umumiy',
    'Ichimliklar',
    'Shirinliklar',
    'Oziq-ovqat',
    'Uy-ro\'zg\'or',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
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

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      AppSnackBar.error(context, "Iltimos, kategoriyani tanlang");
      return;
    }

    setState(() => _isSaving = true);

    final enteredQty = int.tryParse(_qtyController.text) ?? 0;
    final perBox = int.tryParse(_itemsInBoxController.text) ?? 1;
    // "Karobka" rejimida umumiy dona soni = karobkalar soni x har birida
    // nechtadan borligi. Omborga faqat yakuniy dona soni yoziladi.
    final finalStock = (_tabController.index == 1)
        ? (enteredQty * perBox)
        : enteredQty;

    context.read<ProductBloc>().add(
      AddProduct(
        ProductModel(
          id: '',
          name: _nameController.text.trim(),
          barcode: _barcodeController.text.trim(),
          stock: finalStock,
          sellPrice: double.tryParse(_salePriceController.text) ?? 0,
          buyPrice: double.tryParse(_purchasePriceController.text) ?? 0,
          category: _selectedCategory,
          description: _descriptionController.text.trim(),
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
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Yangi mahsulot',
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
              Tab(icon: Icon(Icons.inventory_2_outlined), text: "Dona"),
              Tab(icon: Icon(Icons.all_inbox_rounded), text: "Karobka"),
            ],
          ),
        ),
        body: SingleChildScrollView(
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
            _tabController.index == 0
                ? "Dona bo'yicha kiritish"
                : "Karobka bo'yicha kiritish",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.forestDark,
            ),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: "Shtrix-kod",
            controller: _barcodeController,
            suffixIcon: Icons.qr_code_scanner_rounded,
          ),
          CustomTextField(
            label: "Mahsulot nomi",
            controller: _nameController,
            hint: "masalan: Redbull",
            validator: (v) => Validators.required(v, "Nomi"),
          ),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: _tabController.index == 0
                      ? "Miqdor (Dona)"
                      : "Karobkalar soni",
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  validator: Validators.quantity,
                ),
              ),
              if (_tabController.index == 1) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    label: "1 karobkada dona",
                    controller: _itemsInBoxController,
                    keyboardType: TextInputType.number,
                    validator: Validators.quantity,
                  ),
                ),
              ],
            ],
          ),

          _buildDropdownLabel("Kategoriya"),
          _buildCategoryDropdown(),

          CustomTextField(
            label: "Sotish narxi",
            controller: _salePriceController,
            keyboardType: TextInputType.number,
            validator: Validators.price,
          ),
          CustomTextField(
            label: "Tannarx",
            controller: _purchasePriceController,
            keyboardType: TextInputType.number,
            validator: Validators.price,
          ),
          CustomTextField(
            label: "Tavsif",
            controller: _descriptionController,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

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
      initialValue: _selectedCategory,
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
        onPressed: _isSaving ? null : _saveProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                "Mahsulot qo'shish",
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
