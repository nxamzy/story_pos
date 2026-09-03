import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/core/widgets/app_state_views.dart';
import 'package:ocam_pos/data/models/sale_model.dart';
import 'package:ocam_pos/injection.dart';
import 'package:ocam_pos/presentation/refunds/bloc/refunds_bloc.dart';
import 'package:ocam_pos/presentation/refunds/bloc/refunds_event.dart';
import 'package:ocam_pos/presentation/refunds/bloc/refunds_state.dart';

/// So'nggi 30 kunda qaytarilgan savdolar.
///
/// Savdo cheki ekranidagi "Savdoni qaytarish" amali shu ro'yxatga tushadi.
class RefundsPage extends StatelessWidget {
  const RefundsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RefundsBloc>(
      create: (_) => sl<RefundsBloc>()..add(const LoadRefunds()),
      child: const _RefundsView(),
    );
  }
}

class _RefundsView extends StatelessWidget {
  const _RefundsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: const Text(
          "Qaytarishlar",
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<RefundsBloc, RefundsState>(
        builder: (context, state) {
          if (state.status.isFirstLoad) {
            return const AppLoader();
          }

          if (state.status.isFailure) {
            return AppErrorView(
              message: state.error ?? "Ro'yxatni yuklab bo'lmadi",
              onRetry: () =>
                  context.read<RefundsBloc>().add(const LoadRefunds()),
            );
          }

          if (state.sales.isEmpty) {
            return const AppEmptyView(
              icon: Icons.undo_rounded,
              message: "So'nggi 30 kunda qaytarilgan savdo yo'q",
            );
          }

          return Column(
            children: [
              _Summary(count: state.sales.length, total: state.totalAmount),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.sales.length,
                  itemBuilder: (context, index) =>
                      _RefundTile(sale: state.sales[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final int count;
  final double total;

  const _Summary({required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.undo_rounded, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$count ta qaytarilgan savdo",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.forestDark,
              ),
            ),
          ),
          Text(
            AppFormat.money(total),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.error,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _RefundTile extends StatelessWidget {
  final SaleModel sale;

  const _RefundTile({required this.sale});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(PlatformRoutes.receiptPage.route, extra: sale),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.mintLight),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.background,
              child: Icon(Icons.receipt_outlined, color: AppColors.error),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sale.customerName?.isNotEmpty == true
                        ? sale.customerName!
                        : "Chek #${sale.id.length >= 6 ? sale.id.substring(0, 6) : sale.id}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.forestDark,
                    ),
                  ),
                  Text(
                    "Sotilgan: ${AppFormat.date(sale.createdAt)}"
                    "${sale.refundedAt == null ? '' : " · Qaytarilgan: ${AppFormat.date(sale.refundedAt)}"}",
                    style: const TextStyle(
                      color: AppColors.sage,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              AppFormat.money(sale.total),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
