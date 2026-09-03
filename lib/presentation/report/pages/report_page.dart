import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/data/models/sale_model.dart';
import 'package:ocam_pos/presentation/report/bloc/report_bloc.dart';
import 'package:ocam_pos/presentation/report/bloc/report_event.dart';
import 'package:ocam_pos/presentation/report/bloc/report_state.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReportBloc>().add(LoadReport(DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hisobotlar',
          style: TextStyle(
            fontSize: 22,
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildHorizontalCalendar(state.selectedDate),
              const Divider(height: 1, color: AppColors.mintLight),
              Expanded(
                child: state.status.isFirstLoad
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          const SliverToBoxAdapter(child: SizedBox(height: 24)),

                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverGrid.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.4,
                              children: [
                                _buildStatCard(
                                  Icons.show_chart_rounded,
                                  Colors.blue,
                                  AppFormat.money(state.todayTotal),
                                  "Bugungi savdo",
                                ),
                                _buildStatCard(
                                  Icons.calendar_today_rounded,
                                  Colors.purple,
                                  AppFormat.money(state.yearlyTotal),
                                  "Yillik savdo",
                                ),
                                _buildStatCard(
                                  Icons.account_balance_wallet_rounded,
                                  AppColors.primary,
                                  AppFormat.money(state.netIncome),
                                  "Sof foyda",
                                ),
                                _buildStatCard(
                                  Icons.inventory_2_outlined,
                                  Colors.orange,
                                  "${state.productsSold}",
                                  "Sotilgan mahsulot",
                                ),
                              ],
                            ),
                          ),

                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 32, 20, 16),
                              child: Text(
                                "So'nggi savdolar",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.forestDark,
                                ),
                              ),
                            ),
                          ),

                          if (state.todaySales.isEmpty)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 20,
                                ),
                                child: Center(
                                  child: Text(
                                    "Bu kunda savdo bo'lmagan",
                                    style: TextStyle(color: AppColors.sage),
                                  ),
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildTransactionItem(
                                    state.todaySales[index],
                                  ),
                                  childCount: state.todaySales.length,
                                ),
                              ),
                            ),
                          const SliverToBoxAdapter(child: SizedBox(height: 30)),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHorizontalCalendar(DateTime selectedDate) {
    final today = DateTime.now();
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: days
              .map(
                (date) => _calendarItem(
                  date,
                  isSelected: _isSameDay(date, selectedDate),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _calendarItem(DateTime date, {bool isSelected = false}) {
    const weekdays = ['Du', 'Se', 'Cho', 'Pay', 'Ju', 'Sh', 'Ya'];
    return GestureDetector(
      onTap: () => context.read<ReportBloc>().add(SelectReportDate(date)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? null : Border.all(color: AppColors.mintLight),
        ),
        child: Column(
          children: [
            Text(
              "${date.day}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.white : AppColors.forestDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              weekdays[date.weekday - 1],
              style: TextStyle(
                color: isSelected
                    ? AppColors.white.withValues(alpha: 0.8)
                    : AppColors.sage,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    Color iconColor,
    String value,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mintLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.forestDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.sage, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(SaleModel sale) {
    return InkWell(
      // Har bir qator o'z chekini ochadi — ilgari chek faqat savdo
      // yakunlangan zahoti ko'rish mumkin edi.
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
              child: Icon(Icons.receipt_outlined, color: AppColors.primary),
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
                    AppFormat.time(sale.createdAt),
                    style: const TextStyle(color: AppColors.sage, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              AppFormat.money(sale.total),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.sage),
          ],
        ),
      ),
    );
  }
}
