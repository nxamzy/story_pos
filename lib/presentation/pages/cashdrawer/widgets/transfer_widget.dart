import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class TransferWidget extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController noteController;

  const TransferWidget({
    super.key,
    required this.amountController,
    required this.noteController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Amount",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.attach_money),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: noteController,
          decoration: InputDecoration(
            labelText: "Note (Optional)",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.note_add),
          ),
        ),
      ],
    );
  }
}

class TransfermButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  const TransfermButtonWidget({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Transfer Balance",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
