import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_bloc.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_event.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_state.dart';

void showDeleteConfirmation(
  BuildContext context, {
  required String customerId,
  required String customerName,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<CustomerBloc>(),
      child: DeleteCustomerSheet(
        customerId: customerId,
        customerName: customerName,
      ),
    ),
  );
}

class DeleteCustomerSheet extends StatefulWidget {
  final String customerId, customerName;
  const DeleteCustomerSheet({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<DeleteCustomerSheet> createState() => _DeleteCustomerSheetState();
}

class _DeleteCustomerSheetState extends State<DeleteCustomerSheet> {
  bool isChecked = false;
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerBloc, CustomerState>(
      listenWhen: (previous, current) =>
          current.actionMessage != null || current.error != null,
      listener: (context, state) {
        if (state.error != null) {
          setState(() => _isDeleting = false);
          AppSnackBar.error(context, state.error!);
        } else if (state.actionMessage != null) {
          AppSnackBar.success(context, "Mijoz o'chirildi");
          // Ro'yxatdan ochilgan bo'lishi mumkin (sheet only) yoki tafsilot
          // sahifasidan (sheet + o'sha sahifa) — ikkalasini ham yopamiz.
          Navigator.pop(context);
          if (context.canPop()) context.pop();
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.delete_sweep_rounded,
              size: 60,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              "${widget.customerName} o'chirilsinmi?",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Bu amalni ortga qaytarib bo'lmaydi.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              value: isChecked,
              onChanged: (v) => setState(() => isChecked = v ?? false),
              title: const Text(
                "Ha, o'chirmoqchiman",
                style: TextStyle(fontSize: 14),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primary,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (isChecked && !_isDeleting)
                    ? () {
                        setState(() => _isDeleting = true);
                        context.read<CustomerBloc>().add(
                          DeleteCustomerEvent(widget.customerId),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isDeleting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "O'chirishni tasdiqlash",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text(
                "Bekor qilish",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
