import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/core/widgets/app_search_field.dart';
import 'package:ocam_pos/core/widgets/app_state_views.dart';
import 'package:ocam_pos/data/models/sale_model.dart';
import 'package:ocam_pos/injection.dart';
import 'package:ocam_pos/presentation/sales_history/bloc/sales_history_bloc.dart';
import 'package:ocam_pos/presentation/sales_history/bloc/sales_history_event.dart';
import 'package:ocam_pos/presentation/sales_history/bloc/sales_history_state.dart';

/// Savdolar tarixi: davr bo'yicha barcha cheklar.
///
/// Hisobot bitta kunni ko'rsatadi; bu yerda esa eski chekni sana oralig'i
/// va qidiruv orqali topish mumkin.
class SalesHistoryPage extends StatelessWidget {
  const SalesHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));
    final to = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: 1));

    return BlocProvider<SalesHistoryBloc>(
      create: (_) =>
          sl<SalesHistoryBloc>()..add(LoadSalesHistory(from: from, to: to)),
      child: const _SalesHistoryView(),
    );
  }
}

class _SalesHistoryView extends StatelessWidget {
  const _SalesHistoryView();

  Future<void> _pickRange(BuildContext context, SalesHistoryState state) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: (state.from != null && state.to != null)
          ? DateTimeRange(
              start: state.from!,
              // Oxirgi kun so'rovda "kun boshigacha" bo'lgani uchun
              // ko'rsatishda bir kun orqaga suriladi.
              end: state.to!.subtract(const Duration(days: 1)),
            )
          : null,
      helpText: "Davrni tanlang",
      saveText: "Tanlash",
    );
    if (picked == null || !context.mounted) return;

    context.read<SalesHistoryBloc>().add(
      LoadSalesHistory(
        from: DateTime(
          picked.start.year,
          picked.start.month,
          picked.start.day,
        ),
        to: DateTime(
          picked.end.year,
          picked.end.month,
          picked.end.day,
        ).add(const Duration(days: 1)),
      ),
    );
  }

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
          "Savdolar tarixi",
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          BlocBuilder<SalesHistoryBloc, SalesHistoryState>(
            builder: (context, state) => IconButton(
              tooltip: "Davrni tanlash",
              onPressed: () => _pickRange(context, state),
              icon: const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<SalesHistoryBloc, SalesHistoryState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildHeader(context, state),
              Expanded(child: _buildBody(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SalesHistoryState state) {
    final period = (state.from == null || state.to == null)
        ? ''
        : "${AppFormat.date(state.from)} — "
              "${AppFormat.date(state.to!.subtract(const Duration(days: 1)))}";

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.mintLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        period,
                        style: const TextStyle(
                          color: AppColors.sage,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${state.visibleSales.length} ta savdo",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.forestDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  AppFormat.money(state.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppSearchField(
            hint: "Mijoz, kassir yoki chek raqami",
            onChanged: (value) => context.read<SalesHistoryBloc>().add(
              SearchSalesHistory(value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, SalesHistoryState state) {
    if (state.status.isFirstLoad) return const AppLoader();

    if (state.status.isFailure) {
      return AppErrorView(
        message: state.error ?? "Savdolarni yuklab bo'lmadi",
        onRetry: () {
          final from = state.from;
          final to = state.to;
          if (from == null || to == null) return;
          context.read<SalesHistoryBloc>().add(
            LoadSalesHistory(from: from, to: to),
          );
        },
      );
    }

    final sales = state.visibleSales;
    if (sales.isEmpty) {
      return AppEmptyView(
        icon: Icons.receipt_long_outlined,
        message: state.sales.isEmpty
            ? "Bu davrda savdo bo'lmagan"
            : "Qidiruv bo'yicha savdo topilmadi",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: sales.length,
      itemBuilder: (context, index) => _SaleTile(sale: sales[index]),
    );
  }
}

class _SaleTile extends StatelessWidget {
  final SaleModel sale;

  const _SaleTile({required this.sale});

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
            CircleAvatar(
              backgroundColor: AppColors.background,
              child: Icon(
                Icons.receipt_outlined,
                color: sale.refunded ? AppColors.error : AppColors.primary,
              ),
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
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${AppFormat.dateTime(sale.createdAt)} · "
                    "${sale.itemCount} dona"
                    "${sale.cashierName == null || sale.cashierName!.isEmpty ? '' : ' · ${sale.cashierName}'}",
                    style: const TextStyle(
                      color: AppColors.sage,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (sale.refunded)
                    const Text(
                      "Qaytarilgan",
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              AppFormat.money(sale.total),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: sale.refunded ? AppColors.sage : AppColors.primary,
                decoration: sale.refunded ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
