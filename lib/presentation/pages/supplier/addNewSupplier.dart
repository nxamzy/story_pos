import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/data/models/supplier_model.dart'; // To'g'ri path qo'y
import 'package:ocam_pos/data/repositories/supplier_repository.dart'; // To'g'ri path qo'y
import 'package:ocam_pos/presentation/widgets/supplier_widget/add/add_supplier_text_field.dart';
import 'add_successfully_supplier.dart';

class AddSupplierScreen extends StatefulWidget {
  const AddSupplierScreen({super.key});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = SupplierRepository();
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  Future<void> _saveSupplier() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final supplier = SupplierModel(
          id: '',
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
          notes: _notesController.text.trim(),
          imageUrl: 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
          createdAt: DateTime.now(),
        );

        await _repository.addSupplier(supplier);

        if (mounted) {
          showSupplierSuccessSheet(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Xato yuz berdi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Add New Supplier',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildCard(
                title: "Personal Information",
                children: [
                  _buildImagePickerPlaceholder(),
                  const SizedBox(height: 24),
                  AddSupplierTextField(
                    label: "Supplier Name",
                    controller: _nameController,
                    validator: (v) => v!.isEmpty ? "Ismni kiriting" : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildCard(
                title: "Contact Data",
                children: [
                  AddSupplierTextField(
                    label: "Phone Number",
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? "Raqamni kiriting" : null,
                  ),
                  AddSupplierTextField(
                    label: "Email Address",
                    controller: _emailController,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildCard(
                title: "Address & Logistics",
                children: [
                  AddSupplierTextField(
                    label: "Full Address",
                    controller: _addressController,
                  ),
                  AddSupplierTextField(
                    label: "Notes",
                    controller: _notesController,
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSaveButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerPlaceholder() {
    return Center(
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.mintMedium),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 30),
            SizedBox(height: 4),
            Text(
              "Add Image",
              style: TextStyle(color: AppColors.sage, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveSupplier,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Create Supplier",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
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
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.forestDark,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
