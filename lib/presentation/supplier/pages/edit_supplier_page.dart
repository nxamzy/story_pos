import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/validators.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/data/models/supplier_model.dart';
import 'package:ocam_pos/presentation/supplier/bloc/supplier_bloc.dart';
import 'package:ocam_pos/presentation/supplier/bloc/supplier_event.dart';
import 'package:ocam_pos/presentation/supplier/bloc/supplier_state.dart';
import 'package:ocam_pos/presentation/supplier/widgets/edit_field_widget.dart';

void showEditSupplierSheet(BuildContext context, SupplierModel supplier) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<SupplierBloc>(),
      child: EditSupplierSheet(supplier: supplier),
    ),
  );
}

class EditSupplierSheet extends StatefulWidget {
  final SupplierModel supplier;
  const EditSupplierSheet({super.key, required this.supplier});

  @override
  State<EditSupplierSheet> createState() => _EditSupplierSheetState();
}

class _EditSupplierSheetState extends State<EditSupplierSheet> {
  final _formKey = GlobalKey<FormState>();
  late final nameController = TextEditingController(text: widget.supplier.name);
  late final phoneController = TextEditingController(text: widget.supplier.phone);
  late final emailController = TextEditingController(text: widget.supplier.email);
  late final addressController =
      TextEditingController(text: widget.supplier.address);
  late final notesController = TextEditingController(text: widget.supplier.notes);

  bool _isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    context.read<SupplierBloc>().add(
      UpdateSupplier(
        widget.supplier.copyWith(
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          email: emailController.text.trim(),
          address: addressController.text.trim(),
          notes: notesController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SupplierBloc, SupplierState>(
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
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 12,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.mintMedium,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Row(
                  children: [
                    Icon(Icons.edit_note, color: AppColors.primary, size: 28),
                    SizedBox(width: 8),
                    Text(
                      "Ta'minotchi ma'lumotini tahrirlash",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.forestDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                EditFieldWidget(
                  label: "Nomi",
                  controller: nameController,
                  hasClearIcon: true,
                  validator: (v) => Validators.required(v, "Nomi"),
                ),
                EditFieldWidget(
                  label: "Telefon raqami",
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                EditFieldWidget(
                  label: "Email",
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                EditFieldWidget(label: "Manzil", controller: addressController),
                EditFieldWidget(
                  label: "Eslatma",
                  controller: notesController,
                  maxLines: 3,
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "O'zgarishlarni saqlash",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
