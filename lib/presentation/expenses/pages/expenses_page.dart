import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/core/widgets/app_state_views.dart';
import 'package:ocam_pos/core/widgets/confirm_dialog.dart';
import 'package:ocam_pos/data/models/expense_model.dart';
import 'package:ocam_pos/presentation/cashdrawer/bloc/cash_bloc.dart';
import 'package:ocam_pos/presentation/cashdrawer/bloc/cash_event.dart';
import 'package:ocam_pos/presentation/cashdrawer/bloc/cash_state.dart';
import 'package:ocam_pos/presentation/expenses/bloc/expense_bloc.dart';
import 'package:ocam_pos/presentation/expenses/bloc/expense_event.dart';
import 'package:ocam_pos/presentation/expenses/bloc/expense_state.dart';
import 'package:ocam_pos/presentation/expenses/widgets/add_expense_sheet.dart';

/// Do'kon xarajatlari: ijara, kommunal, transport va hokazo.
///
/// Kassadan to'langan xarajat kassa balansini kamaytiradi — shu sababli
/// sahifada kassadagi mavjud mablag' ham ko'rsatiladi.
class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(const LoadExpenses());
    // Kassa balansi xarajat qo'shish varag'ida kerak bo'ladi.
    context.read<CashBloc>().add(const LoadCashDrawer());
  }

  Future<void> _confirmDelete(BuildContext context, ExpenseModel expense) async {
    final confirmed = await showConfirmDialog(
      context,
      title: "Xarajatni o'chirish",
      message: expense.fromDrawer
          ? "\"${expense.title}\" o'chirilsinmi? "
                "${AppFormat.money(expense.amount)} kassaga qaytariladi."
          : "\"${expense.title}\" o'chirilsinmi?",
      confirmLabel: "Ha, o'chirish",
    );
    if (!confirmed || !context.mounted) return;

    context.read<ExpenseBloc>().add(DeleteExpense(expense.id));
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
          "Xarajatlar",
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => showAddExpenseSheet(
          context,
          drawerBalance: context.read<CashBloc>().state.balance,
        ),
        icon: const Icon(Icons.add),
        label: const Text("Xarajat"),
      ),
      body: BlocListener<ExpenseBloc, ExpenseState>(
        listenWhen: (previous, current) =>
            current.error != null || current.actionMessage != null,
        listener: (context, state) {
          if (state.error != null) {
            AppSnackBar.error(context, state.error!);
          } else if (state.actionMessage != null) {
            // O'chirish ham shu yerda tasdiqlanadi — ilgari hech qanday
            // xabar chiqmasdi.
            AppSnackBar.success(context, state.actionMessage!);
          }
        },
        child: BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {
            if (state.status.isFirstLoad && state.expenses.isEmpty) {
              return const AppLoader();
            }

            return Column(
              children: [
                _buildSummary(state),
                _buildCategoryChips(context, state),
                Expanded(child: _buildList(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummary(ExpenseState state) {
    return BlocBuilder<CashBloc, CashState>(
      builder: (context, cashState) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.mintLight),
          ),
          child: Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: "Shu oydagi xarajat",
                  value: AppFormat.money(state.monthTotal),
                ),
              ),
              Container(width: 1, height: 34, color: AppColors.mintLight),
              Expanded(
                child: _SummaryItem(
                  label: "Kassada bor",
                  value: AppFormat.money(cashState.balance),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChips(BuildContext context, ExpenseState state) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          final category = state.categories[index];
          final isSelected = state.category == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => context.read<ExpenseBloc>().add(
                FilterExpensesByCategory(category),
              ),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.white,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.white : AppColors.forestDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: const BorderSide(color: AppColors.mintLight),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, ExpenseState state) {
    final expenses = state.visibleExpenses;

    if (expenses.isEmpty) {
      return AppEmptyView(
        icon: Icons.payments_outlined,
        message: state.expenses.isEmpty
            ? "Hozircha xarajat yozilmagan.\nIjara, kommunal va boshqa "
                  "to'lovlarni shu yerda yuritishingiz mumkin."
            : "Bu turdagi xarajat yo'q",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
      physics: const BouncingScrollPhysics(),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return _ExpenseTile(
          expense: expense,
          onDelete: () => _confirmDelete(context, expense),
        );
      },
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.sage, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.forestDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onDelete;

  const _ExpenseTile({required this.expense, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mintLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.mintLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.forestDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "${expense.category} · ${AppFormat.date(expense.createdAt)}"
                  "${expense.fromDrawer ? ' · Kassadan' : ''}",
                  style: const TextStyle(color: AppColors.sage, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                if (expense.note.isNotEmpty)
                  Text(
                    expense.note,
                    style: const TextStyle(
                      color: AppColors.mintMedium,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormat.money(expense.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AppColors.sage,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
