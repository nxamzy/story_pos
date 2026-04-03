import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/data/models/customer_model.dart';
import 'package:ocam_pos/presentation/pages/customers/bloc/customer_bloc.dart';
import 'package:ocam_pos/presentation/widgets/customer_widget/details_section_card.dart';

class AddNewCustomerPage extends StatefulWidget {
  const AddNewCustomerPage({super.key});

  @override
  State<AddNewCustomerPage> createState() => _AddNewCustomerPageState();
}

class _AddNewCustomerPageState extends State<AddNewCustomerPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final altPhoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final notesController = TextEditingController();

  bool _isLoading = false;
  File? _selectedImage;
  bool _showAltPhone = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    altPhoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    cityController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Iltimos, ism va telefon raqamini kiriting!');
      return;
    }

    setState(() => _isLoading = true);

    final String customerId = FirebaseFirestore.instance
        .collection('users')
        .doc()
        .id;

    final newCustomer = CustomerModel(
      id: customerId,
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      address: "${cityController.text.trim()} ${addressController.text.trim()}"
          .trim(),
      notes: notesController.text.trim(),
      totalSpent: 0.0,
      createdAt: DateTime.now(),
    );

    context.read<CustomerBloc>().add(AddManualCustomerEvent(newCustomer));

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccessSnackBar('Mijoz muvaffaqiyatli saqlandi!');
        context.pop();
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildPersonalSection(),
                      const SizedBox(height: 16),
                      _buildContactSection(),
                      const SizedBox(height: 16),
                      _buildAddressSection(),
                      const SizedBox(height: 16),
                      _buildNotesSection(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              _buildActionFooter(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: AppColors.primary,
          size: 20,
        ),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'New Customer Profile',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildPersonalSection() {
    return DetailsSectionCard(
      title: "Identity Information",
      child: Column(
        children: [
          _ImageUploadPicker(
            imageFile: _selectedImage,
            onTap: () => setState(() => _selectedImage = File('picked')),
          ),
          const SizedBox(height: 24),
          _HeavyDutyTextField(
            label: "Full Name",
            hint: "Enter customer full name",
            controller: nameController,
            prefixIcon: Icons.person_outline,
            validator: (v) =>
                (v == null || v.isEmpty) ? "Name is required" : null,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return DetailsSectionCard(
      title: "Contact Data",
      child: Column(
        children: [
          _HeavyDutyTextField(
            label: "Primary Phone",
            hint: "+998 90 123 45 67",
            controller: phoneController,
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) =>
                (v == null || v.length < 7) ? "Phone is required" : null,
          ),
          const SizedBox(height: 12),
          if (_showAltPhone) ...[
            _HeavyDutyTextField(
              label: "Secondary Phone",
              hint: "Alternative contact",
              controller: altPhoneController,
              prefixIcon: Icons.add_call,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
          ],
          _HeavyDutyTextField(
            label: "Email Address",
            hint: "customer@domain.com",
            controller: emailController,
            prefixIcon: Icons.alternate_email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          if (!_showAltPhone)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _showAltPhone = true),
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Add Alternative Phone"),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return DetailsSectionCard(
      title: "Location Details",
      child: Column(
        children: [
          _HeavyDutyTextField(
            label: "City",
            hint: "e.g. Tashkent",
            controller: cityController,
            prefixIcon: Icons.location_city_outlined,
          ),
          const SizedBox(height: 12),
          _HeavyDutyTextField(
            label: "Street Address",
            hint: "District, House number...",
            controller: addressController,
            prefixIcon: Icons.map_outlined,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return DetailsSectionCard(
      title: "Additional Notes",
      child: _HeavyDutyTextField(
        label: "Internal Notes",
        hint: "Preferences or special terms...",
        controller: notesController,
        prefixIcon: Icons.edit_note_outlined,
        maxLines: 3,
      ),
    );
  }

  Widget _buildActionFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  "Save Customer Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

class _HeavyDutyTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _HeavyDutyTextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.forestDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.sage.withOpacity(0.6),
              fontSize: 14,
            ),
            prefixIcon: Icon(prefixIcon, color: AppColors.sage, size: 20),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageUploadPicker extends StatelessWidget {
  final VoidCallback onTap;
  final File? imageFile;
  const _ImageUploadPicker({required this.onTap, this.imageFile});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: AppColors.mintLight, width: 2),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 30),
            SizedBox(height: 4),
            Text(
              "Photo",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
