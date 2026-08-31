import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/data/models/user_model.dart';
import 'package:ocam_pos/presentation/customers/widgets/customer_text_field.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_bloc.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_event.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_state.dart';

void showEditProfileSheet(BuildContext context, UserModel user) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
      ),
      child: BlocProvider.value(
        value: context.read<ProfileBloc>(),
        child: EditProfileSheet(user: user),
      ),
    ),
  );
}

class EditProfileSheet extends StatefulWidget {
  final UserModel user;
  const EditProfileSheet({super.key, required this.user});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final firstNameController = TextEditingController(
    text: widget.user.firstName,
  );
  late final lastNameController = TextEditingController(
    text: widget.user.lastName,
  );
  late final phoneController = TextEditingController(text: widget.user.phone);

  bool _isSaving = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _onSave() {
    setState(() => _isSaving = true);
    context.read<ProfileBloc>().add(
      UpdateUserProfile(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phone: phoneController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
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
                "Profilni tahrirlash",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestDark,
                ),
              ),
              const SizedBox(height: 25),
              CustomInputField(label: "Ism", controller: firstNameController),
              const SizedBox(height: 12),
              CustomInputField(
                label: "Familiya",
                controller: lastNameController,
              ),
              const SizedBox(height: 12),
              CustomInputField(
                label: "Telefon raqami",
                controller: phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 30),
              _buildSaveButton(),
              const SizedBox(height: 10),
            ],
          ),
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _onSave,
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
                "Saqlash",
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
