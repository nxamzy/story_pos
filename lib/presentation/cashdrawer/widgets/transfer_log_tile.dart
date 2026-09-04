import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/data/models/transfer_log_model.dart';

/// Kassa <-> xodim o'tkazmasining bitta qatori.
///
/// Kassa sahifasida oxirgi 10 tasi, "O'tkazmalar tarixi" sahifasida esa
/// hammasi shu widget bilan chiziladi.
class TransferLogTile extends StatelessWidget {
  final TransferLogModel log;

  const TransferLogTile({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.mintLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.swap_horiz_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${log.fromName} -> ${log.toName}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.forestDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  log.note.isEmpty
                      ? AppFormat.dateTime(log.createdAt)
                      : "${AppFormat.dateTime(log.createdAt)} · ${log.note}",
                  style: const TextStyle(color: AppColors.sage, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            AppFormat.money(log.amount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
