import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart'; // AppColors importi

class TransferWidget extends StatefulWidget {
  const TransferWidget({super.key});

  @override
  State<TransferWidget> createState() => _TransferWidgetState();
}

class _TransferWidgetState extends State<TransferWidget> {
  // Controllerlarni klass ichida e'lon qilish tartibning birinchi qoidasi!
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.mintLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestDark.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize:
              MainAxisSize.min, // Container balandligini kontentga moslaydi
          children: [
            const Text(
              "Transfer Balance",
              style: TextStyle(
                color: AppColors.forestDark,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Divider(color: AppColors.mintLight, thickness: 1, height: 30),

            // --- FROM FIELD ---
            _buildLabel("From"),
            const SizedBox(height: 8),
            _buildTransferField(
              controller: fromController,
              hintText: "Employee Name",
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 20),

            // --- TO FIELD ---
            _buildLabel("To"),
            const SizedBox(height: 8),
            _buildTransferField(
              controller: toController,
              hintText: "Select Employee",
              icon: Icons.keyboard_arrow_down,
            ),
          ],
        ),
      ),
    );
  }

  // --- YORDAMCHI METODLAR ---

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.primary, // Emerald Green
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _buildTransferField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.sage, fontSize: 14),
        suffixIcon: Icon(icon, color: AppColors.primary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        filled: true,
        fillColor: AppColors.background,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mintLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
