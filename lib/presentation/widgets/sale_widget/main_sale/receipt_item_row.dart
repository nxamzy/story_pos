import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class ReceiptItemRow extends StatelessWidget {
  final String name;
  final String qty;
  final String price;
  final bool isHeader;

  const ReceiptItemRow({
    super.key,
    required this.name,
    required this.qty,
    required this.price,
    this.isHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: isHeader ? FontWeight.bold : FontWeight.w600,
      color: isHeader ? AppColors.sage : AppColors.forestDark,
      fontSize: isHeader ? 13 : 15,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(name, textAlign: TextAlign.left, style: style),
          ),
          Expanded(
            child: Text(qty, textAlign: TextAlign.center, style: style),
          ),
          Expanded(
            child: Text(price, textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }
}
