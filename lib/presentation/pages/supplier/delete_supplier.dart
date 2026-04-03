import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/presentation/widgets/supplier_widget/delete/delete_confirmation_checkbox.dart';

void showDeleteSupplier(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const DeleteSupplierSheet(),
  );
}

class DeleteSupplierSheet extends StatefulWidget {
  const DeleteSupplierSheet({super.key});

  @override
  State<DeleteSupplierSheet> createState() => _DeleteSupplierSheetState();
}

class _DeleteSupplierSheetState extends State<DeleteSupplierSheet> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            decoration: BoxDecoration(
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
            "Are you sure to delete this supplier?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.forestDark,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "This action cannot be undone and all data related to this supplier will be removed.",
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
              onPressed: isChecked
                  ? () {
                      debugPrint("Supplier deleted!");
                      Navigator.pop(context);
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
              child: const Text(
                "Delete Supplier",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: AppColors.sage,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
