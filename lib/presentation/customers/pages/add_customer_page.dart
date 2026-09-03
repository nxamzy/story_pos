import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/validators.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/data/models/customer_model.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_bloc.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_event.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_state.dart';
import 'package:ocam_pos/presentation/customers/widgets/details_section_card.dart';
import 'package:ocam_pos/presentation/customers/widgets/customer_added_sheet.dart';

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

  bool _isSaving = false;
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final newCustomer = CustomerModel(
      id: '',
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      // Kiritilgan qo'shimcha raqam ilgari hech qayerga yozilmasdi.
      altPhone: altPhoneController.text.trim(),
      email: emailController.text.trim(),
      address:
          "${cityController.text.trim()} ${addressController.text.trim()}"
              .trim(),
      notes: notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    context.read<CustomerBloc>().add(SaveCustomerEvent(newCustomer));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerBloc, CustomerState>(
      listenWhen: (previous, current) =>
          current.actionMessage != null || current.error != null,
      listener: (context, state) {
        if (state.error != null) {
          setState(() => _isSaving = false);
          AppSnackBar.error(context, state.error!);
        } else if (state.actionMessage != null && state.createdCustomer != null) {
          showSuccessInventory(context, state.createdCustomer!);
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
        'Yangi mijoz profili',
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
      title: "Shaxsiy ma'lumot",
      child: _HeavyDutyTextField(
        label: "To'liq ism",
        hint: "Mijozning to'liq ismi",
        controller: nameController,
        prefixIcon: Icons.person_outline,
        validator: (v) => Validators.required(v, "Ism"),
      ),
    );
  }

  Widget _buildContactSection() {
    return DetailsSectionCard(
      title: "Aloqa ma'lumotlari",
      child: Column(
        children: [
          _HeavyDutyTextField(
            label: "Asosiy telefon",
            hint: "+998 90 123 45 67",
            controller: phoneController,
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: Validators.phone,
          ),
          const SizedBox(height: 12),
          if (_showAltPhone) ...[
            _HeavyDutyTextField(
              label: "Qo'shimcha telefon",
              hint: "Muqobil aloqa",
              controller: altPhoneController,
              prefixIcon: Icons.add_call,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
          ],
          _HeavyDutyTextField(
            label: "Email",
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
                label: const Text("Qo'shimcha telefon qo'shish"),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return DetailsSectionCard(
      title: "Manzil",
      child: Column(
        children: [
          _HeavyDutyTextField(
            label: "Shahar",
            hint: "masalan: Toshkent",
            controller: cityController,
            prefixIcon: Icons.location_city_outlined,
          ),
          const SizedBox(height: 12),
          _HeavyDutyTextField(
            label: "Ko'cha manzili",
            hint: "Tuman, uy raqami...",
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
      title: "Qo'shimcha eslatmalar",
      child: _HeavyDutyTextField(
        label: "Ichki eslatma",
        hint: "Xohish yoki maxsus shartlar...",
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
          onPressed: _isSaving ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                  "Mijoz profilini saqlash",
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
              color: AppColors.sage.withValues(alpha: 0.6),
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
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}
