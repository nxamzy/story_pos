import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/core/utils/pin_hasher.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/data/models/employee_model.dart';
import 'package:ocam_pos/presentation/customers/widgets/customer_text_field.dart';
import 'package:ocam_pos/presentation/employee/bloc/employee_bloc.dart';
import 'package:ocam_pos/presentation/employee/bloc/employee_event.dart';
import 'package:ocam_pos/presentation/employee/bloc/employee_state.dart';

/// Xodim ma'lumotini tahrirlash varag'i.
///
/// `EmployeeBloc`da `UpdateEmployee` eventi allaqachon tayyor edi, lekin uni
/// hech bir ekran chaqirmasdi — xodim profilidagi qalam belgisi faqat
/// "Tez orada" xabarini ko'rsatardi. Shu varaq o'sha bo'shliqni to'ldiradi.
void showEditEmployeeSheet(BuildContext context, EmployeeModel employee) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
      ),
      child: BlocProvider.value(
        value: context.read<EmployeeBloc>(),
        child: EditEmployeeSheet(employee: employee),
      ),
    ),
  );
}

class EditEmployeeSheet extends StatefulWidget {
  final EmployeeModel employee;
  const EditEmployeeSheet({super.key, required this.employee});

  @override
  State<EditEmployeeSheet> createState() => _EditEmployeeSheetState();
}

class _EditEmployeeSheetState extends State<EditEmployeeSheet> {
  late final nameController = TextEditingController(text: widget.employee.name);
  late final roleController = TextEditingController(text: widget.employee.role);
  late final phoneController = TextEditingController(
    text: widget.employee.phone,
  );
  late final altPhoneController = TextEditingController(
    text: widget.employee.altPhone,
  );
  late final salaryController = TextEditingController(
    text: AppFormat.editableNumber(widget.employee.salary),
  );
  late final notesController = TextEditingController(
    text: widget.employee.notes,
  );

  /// Yangi PIN. Bo'sh qoldirilsa mavjud PIN o'zgarmaydi.
  final pinController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    roleController.dispose();
    phoneController.dispose();
    altPhoneController.dispose();
    salaryController.dispose();
    notesController.dispose();
    pinController.dispose();
    super.dispose();
  }

  void _onSave() {
    final pin = pinController.text.trim();
    if (pin.isNotEmpty && !PinHasher.isValidPin(pin)) {
      AppSnackBar.error(context, "PIN ${PinHasher.pinLength} ta raqamdan iborat bo'lsin");
      return;
    }

    setState(() => _isSaving = true);

    context.read<EmployeeBloc>().add(
      // Balans bu yerda tahrirlanmaydi — u faqat kassa o'tkazmalari orqali
      // o'zgaradi, aks holda o'tkazmalar tarixi bilan mos kelmay qoladi.
      UpdateEmployee(
        widget.employee.copyWith(
          name: nameController.text.trim(),
          role: roleController.text.trim(),
          phone: phoneController.text.trim(),
          altPhone: altPhoneController.text.trim(),
          salary:
              double.tryParse(salaryController.text.replaceAll(',', '.')) ??
              widget.employee.salary,
          notes: notesController.text.trim(),
          // PIN kiritilmagan bo'lsa eskisi qoladi; kiritilgan bo'lsa
          // faqat xeshi saqlanadi.
          pinHash: pin.isEmpty
              ? widget.employee.pinHash
              : PinHasher.hash(pin, salt: widget.employee.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EmployeeBloc, EmployeeState>(
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
                "Xodim ma'lumotini tahrirlash",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestDark,
                ),
              ),
              const SizedBox(height: 25),
              CustomInputField(
                label: "To'liq ism",
                controller: nameController,
                showClear: true,
              ),
              const SizedBox(height: 12),
              CustomInputField(label: "Lavozimi", controller: roleController),
              const SizedBox(height: 12),
              CustomInputField(
                label: "Telefon raqami",
                controller: phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              CustomInputField(
                label: "Qo'shimcha telefon",
                controller: altPhoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              CustomInputField(
                label: "Oylik maosh",
                controller: salaryController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CustomInputField(
                label: "Eslatma",
                controller: notesController,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              CustomInputField(
                label: widget.employee.pinHash.isEmpty
                    ? "Kassir PIN kodi (${PinHasher.pinLength} raqam)"
                    : "Yangi PIN (bo'sh qoldirilsa o'zgarmaydi)",
                controller: pinController,
                keyboardType: TextInputType.number,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  "PIN kassir profilini almashtirishda so'raladi. "
                  "Ochiq matnda saqlanmaydi.",
                  style: TextStyle(color: AppColors.sage, fontSize: 11),
                ),
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
