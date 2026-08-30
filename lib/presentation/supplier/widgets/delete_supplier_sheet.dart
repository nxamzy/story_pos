import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/presentation/supplier/bloc/supplier_bloc.dart';
import 'package:ocam_pos/presentation/supplier/bloc/supplier_event.dart';
import 'package:ocam_pos/presentation/supplier/bloc/supplier_state.dart';
import 'package:ocam_pos/presentation/supplier/widgets/delete_confirmation_checkbox.dart';

void showDeleteSupplier(BuildContext context, String supplierId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<SupplierBloc>(),
      child: DeleteSupplierSheet(supplierId: supplierId),
    ),
  );
}

class DeleteSupplierSheet extends StatefulWidget {
  final String supplierId;
  const DeleteSupplierSheet({super.key, required this.supplierId});

  @override
  State<DeleteSupplierSheet> createState() => _DeleteSupplierSheetState();
}

class _DeleteSupplierSheetState extends State<DeleteSupplierSheet> {
  bool isChecked = false;
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SupplierBloc, SupplierState>(
      listenWhen: (previous, current) =>
          current.actionMessage != null || current.error != null,
      listener: (context, state) {
        if (state.error != null) {
          setState(() => _isDeleting = false);
          AppSnackBar.error(context, state.error!);
        } else if (state.actionMessage != null) {
          AppSnackBar.success(context, state.actionMessage!);
          // Sheet va tafsilot sahifasini birga yopamiz.
          Navigator.pop(context);
          if (Navigator.canPop(context)) Navigator.pop(context);
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.mintMedium,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_sweep_outlined,
                size: 54,
                color: AppColors.sage,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Ta'minotchi o'chirilsinmi?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.forestDark,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Bu amalni ortga qaytarib bo'lmaydi va bu ta'minotchiga tegishli barcha ma'lumotlar o'chiriladi.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.sage, fontSize: 14),
            ),
            const SizedBox(height: 24),

            DeleteConfirmationCheckbox(
              isChecked: isChecked,
              onTap: () => setState(() => isChecked = !isChecked),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: (isChecked && !_isDeleting)
                    ? () {
                        setState(() => _isDeleting = true);
                        context
                            .read<SupplierBloc>()
                            .add(DeleteSupplier(widget.supplierId));
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isChecked ? AppColors.primary : AppColors.mintMedium,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  foregroundColor: AppColors.primary,
                  disabledForegroundColor: AppColors.mintMedium,
                ),
                child: _isDeleting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        "Ta'minotchini o'chirish",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 8),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Bekor qilish",
                style: TextStyle(
                  color: AppColors.sage,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
