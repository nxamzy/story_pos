import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/data/models/employee_model.dart';
import 'package:ocam_pos/data/repositories/cash_repository.dart'; // Repositoryni import qilamiz
import 'package:ocam_pos/presentation/pages/cashdrawer/bloc/cash_bloc.dart';
import 'package:ocam_pos/presentation/widgets/customer_widget/details_section_card.dart';

class EmployeeAddPage extends StatefulWidget {
  const EmployeeAddPage({super.key});

  @override
  State<EmployeeAddPage> createState() => _EmployeeAddPageState();
}

class _EmployeeAddPageState extends State<EmployeeAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _repo = CashRepositoryImpl();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final altPhoneController = TextEditingController();
  final salaryController = TextEditingController();
  final balanceController = TextEditingController();
  final roleController = TextEditingController(text: "Employee");
  final notesController = TextEditingController();

  bool _isLoading = false;
  File? _selectedImage;
  bool _showAltPhone = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    altPhoneController.dispose();
    salaryController.dispose();
    balanceController.dispose();
    roleController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _handleSave(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final newEmployee = EmployeeModel(
      id: FirebaseFirestore.instance.collection('employees').doc().id,
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      balance: double.tryParse(balanceController.text.trim()) ?? 0.0,
      role: roleController.text.trim(),
      imageUrl: '',
      salary: double.tryParse(salaryController.text.trim()) ?? 0.0,
      createdAt: DateTime.now(),
    );

    context.read<CashBloc>().addEmployee(newEmployee);
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CashBloc(_repo),
      child: Builder(
        builder: (newContext) {
          return BlocListener<CashBloc, CashState>(
            listener: (context, state) {
              if (state is CashSuccess) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Xodim muvaffaqiyatli saqlandi!"),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                context.pop();
              } else if (state is CashError) {
                setState(() => _isLoading = false);
                _showErrorSnackBar(state.message);
              }
            },
            child: Scaffold(
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
                              _buildFinancialSection(),
                              const SizedBox(height: 16),
                              _buildNotesSection(),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                      _buildActionFooter(newContext),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionFooter(BuildContext context) {
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
          onPressed: _isLoading ? null : () => _handleSave(context),
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
                  "Save Employee Profile",
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
        'New Employee Profile',
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
            hint: "Enter employee full name",
            controller: nameController,
            prefixIcon: Icons.person_outline,
            validator: (v) =>
                (v == null || v.isEmpty) ? "Name is required" : null,
          ),
          const SizedBox(height: 12),
          _HeavyDutyTextField(
            label: "Employee Role",
            hint: "e.g. Cashier, Manager",
            controller: roleController,
            prefixIcon: Icons.badge_outlined,
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

  Widget _buildFinancialSection() {
    return DetailsSectionCard(
      title: "Financial Details",
      child: Column(
        children: [
          _HeavyDutyTextField(
            label: "Monthly Salary",
            hint: "Enter salary amount",
            controller: salaryController,
            prefixIcon: Icons.payments_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _HeavyDutyTextField(
            label: "Opening Balance",
            hint: "Initial cash in hand",
            controller: balanceController,
            prefixIcon: Icons.account_balance_wallet_outlined,
            keyboardType: TextInputType.number,
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
