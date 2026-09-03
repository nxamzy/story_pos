import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/core/utils/validators.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/core/widgets/app_text_field.dart';
import 'package:ocam_pos/data/models/expense_model.dart';
import 'package:ocam_pos/presentation/expenses/bloc/expense_bloc.dart';
import 'package:ocam_pos/presentation/expenses/bloc/expense_event.dart';
import 'package:ocam_pos/presentation/expenses/bloc/expense_state.dart';

/// Yangi xarajat qo'shish varag'i.
void showAddExpenseSheet(BuildContext context, {required double drawerBalance}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
      ),
      child: BlocProvider.value(
        value: context.read<ExpenseBloc>(),
        child: AddExpenseSheet(drawerBalance: drawerBalance),
      ),
    ),
  );
}

class AddExpenseSheet extends StatefulWidget {
  /// Kassadagi mavjud mablag' — foydalanuvchi qancha pul borligini
  /// ko'rib turishi uchun.
  final double drawerBalance;

  const AddExpenseSheet({super.key, required this.drawerBalance});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _category = ExpenseModel.categories.first;
  bool _fromDrawer = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    context.read<ExpenseBloc>().add(
      AddExpense(
        ExpenseModel(
          id: '',
          title: _titleController.text.trim(),
          category: _category,
          amount: AppFormat.parseAmount(_amountController.text),
          note: _noteController.text.trim(),
          fromDrawer: _fromDrawer,
          createdAt: DateTime.now(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpenseBloc, ExpenseState>(
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _buildHandle()),
                const SizedBox(height: 20),
                const Text(
                  "Yangi xarajat",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.forestDark,
                  ),
                ),
                const SizedBox(height: 20),

                AppTextField(
                  label: "Nomi",
                  hint: "masalan: Dekabr ijarasi",
                  controller: _titleController,
                  validator: (v) => Validators.required(v, "Nomi"),
                ),
                const SizedBox(height: 12),
                _buildCategoryDropdown(),
                const SizedBox(height: 12),
                AppTextField(
                  label: "Summa",
                  hint: "0",
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  validator: Validators.price,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: "Izoh (ixtiyoriy)",
                  controller: _noteController,
                  maxLines: 2,
                ),
                const SizedBox(height: 8),

                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _fromDrawer,
                  activeThumbColor: AppColors.primary,
                  onChanged: (value) => setState(() => _fromDrawer = value),
                  title: const Text(
                    "Kassadan to'landi",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _fromDrawer
                        ? "Kassadan yechiladi (mavjud: ${AppFormat.money(widget.drawerBalance)})"
                        : "Kassa balansi o'zgarmaydi",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.sage,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Turi",
          style: TextStyle(color: AppColors.sage, fontSize: 13),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _category,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.mintLight),
            ),
          ),
          items: ExpenseModel.categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (value) =>
              setState(() => _category = value ?? _category),
        ),
      ],
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
