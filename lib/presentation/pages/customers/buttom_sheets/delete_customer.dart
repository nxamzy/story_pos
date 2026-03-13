import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/presentation/pages/customers/bloc/customer_bloc.dart';

void showDeleteConfirmation(
  BuildContext context, {
  required String customerId,
  required String customerName,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        DeleteCustomerSheet(customerId: customerId, customerName: customerName),
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

  @override
  Widget build(BuildContext context) {
    return Container(
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
            "Delete ${widget.customerName}?",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "This action is permanent.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          CheckboxListTile(
            value: isChecked,
            onChanged: (v) => setState(() => isChecked = v!),
            title: const Text(
              "Yes, I want to delete",
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
              onPressed: isChecked
                  ? () {
                      // 1. Bloc'ga o'chirish buyrug'ini beramiz
                      context.read<CustomerBloc>().add(
                        DeleteCustomerEvent(widget.customerId),
                      );

                      // 2. Birinchi pop: BottomSheet'ni yopadi
                      Navigator.of(context).pop();

                      // 3. Ikkinchi pop: Customer Details sahifasidan chiqib, asosiy ro'yxatga qaytadi
                      // Agat GoRouter ishlatsang context.pop() yoki Navigator.pop(context)
                      if (context.canPop()) {
                        context.pop();
                      }

                      // 4. Xabar chiqarish
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Mijoz muvaffaqiyatli o'chirildi"),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Confirm Delete",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
