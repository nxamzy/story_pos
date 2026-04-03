import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/data/models/customer_model.dart';
import 'package:ocam_pos/presentation/pages/customers/bloc/customer_bloc.dart';
import 'package:ocam_pos/presentation/widgets/customer_widget/custom_text_field.dart';

void showEditPersonalData(BuildContext context, CustomerModel customer) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EditPersonalDataSheet(customer: customer), // Mijozni uzatdik
      );
    },
  );
}

class EditPersonalDataSheet extends StatefulWidget {
  final CustomerModel customer; // Tahrirlanayotgan mijoz
  const EditPersonalDataSheet({super.key, required this.customer});

  @override
  State<EditPersonalDataSheet> createState() => _EditPersonalDataSheetState();
}

class _EditPersonalDataSheetState extends State<EditPersonalDataSheet> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController addressController;
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    // Controllerlarni mavjud ma'lumotlar bilan to'ldiramiz
    nameController = TextEditingController(text: widget.customer.name);
    phoneController = TextEditingController(text: widget.customer.phone);
    emailController = TextEditingController(text: widget.customer.email);
    addressController = TextEditingController(text: widget.customer.address);
    notesController = TextEditingController(text: widget.customer.notes);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _onSave(BuildContext context) {
    final updatedCustomer = widget.customer.copyWith(
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      address: addressController.text.trim(),
      notes: notesController.text.trim(),
    );

    context.read<CustomerBloc>().add(AddManualCustomerEvent(updatedCustomer));

    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Ma'lumotlar muvaffaqiyatli yangilandi!"),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _buildHandle()),
            const SizedBox(height: 20),
            const Text(
              "Edit Profile",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.forestDark,
              ),
            ),
            const SizedBox(height: 25),
            CustomInputField(
              label: "Full Name",
              controller: nameController,
              showClear: true,
            ),
            const SizedBox(height: 12),
            CustomInputField(
              label: "Phone Number",
              controller: phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            CustomInputField(
              label: "Email Address",
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            CustomInputField(
              label: "Full Address",
              controller: addressController,
            ),
            const SizedBox(height: 12),
            CustomInputField(
              label: "Notes",
              controller: notesController,
              maxLines: 2,
            ),
            const SizedBox(height: 30),
            _buildSaveButton(context),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() => Container(
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: AppColors.mintLight,
      borderRadius: BorderRadius.circular(10),
    ),
  );

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () => _onSave(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Update Profile",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
