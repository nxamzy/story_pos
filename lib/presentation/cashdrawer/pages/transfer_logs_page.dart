import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/presentation/cashdrawer/bloc/cash_bloc.dart';
import 'package:ocam_pos/presentation/cashdrawer/bloc/cash_state.dart';
import 'package:ocam_pos/presentation/cashdrawer/widgets/transfer_log_tile.dart';

/// Kassa va xodimlar o'rtasidagi barcha o'tkazmalar.
///
/// Kassa sahifasi faqat oxirgi 10 tasini ko'rsatadi; bu yerda `CashBloc`
/// kuzatib turgan to'liq ro'yxat (oxirgi 50 o'tkazma) chiqadi.
class TransferLogsPage extends StatelessWidget {
  const TransferLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
        ),
        title: const Text(
          "O'tkazmalar tarixi",
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<CashBloc, CashState>(
        builder: (context, state) {
          if (state.status.isFirstLoad) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.logs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  "Hozircha o'tkazma yo'q.\n"
                  "Kassa sahifasidan xodimga pul o'tkazsangiz shu yerda "
                  "ko'rinadi.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.sage),
                ),
              ),
            );
          }

          final total = state.logs.fold<double>(
            0,
            (sum, log) => sum + log.amount,
          );

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.mintLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${state.logs.length} ta o'tkazma",
                      style: const TextStyle(
                        color: AppColors.sage,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppFormat.money(total),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.forestDark,
                      ),
                    ),
                    const Text(
                      "Jami ko'chirilgan summa",
                      style: TextStyle(color: AppColors.sage, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    for (final log in state.logs) TransferLogTile(log: log),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
