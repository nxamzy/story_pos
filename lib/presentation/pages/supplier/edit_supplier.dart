import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/presentation/widgets/supplier_widget/edit/edit_field_widget.dart';

void showEditSupplierSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const EditSupplierSheet(),
  );
}

class EditSupplierSheet extends StatelessWidget {
  const EditSupplierSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  "Edit Supplier Data",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.forestDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const EditFieldWidget(
              label: "Name",
              initialValue: "Coca-Cola Wholesale",
              hasClearIcon: true,
            ),
            const EditFieldWidget(
              label: "Phone Number",
              initialValue: "01033970808",
            ),
            const EditFieldWidget(
              label: "VAT Reg No.",
              initialValue: "476381-00174-1738",
            ),
            const EditFieldWidget(
              label: "Address",
              initialValue: "Central Avenue, 28th St.",
            ),
            const EditFieldWidget(
              label: "Notes",
              initialValue: "Regular orders every Monday",
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Save Changes",
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
    );
  }
}
