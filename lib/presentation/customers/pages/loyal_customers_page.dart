import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/data/models/customer_model.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_bloc.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_state.dart';

/// Mijozlar sarflagan summasi bo'yicha tartiblangan ro'yxat.
///
/// "Ko'proq" bo'limidagi "Sodiqlik dasturi" kartochkasi ilgari faqat
/// "Tez orada" xabarini chiqarardi. Ballar va kuponlar tizimi savdo
/// oqimini butunlay qayta yozishni talab qiladi, lekin sodiqlikning eng
/// kerakli ko'rinishi — kim ko'p xarid qilgani — mijoz hujjatidagi
/// `totalSpent` orqali allaqachon mavjud edi.
class LoyalCustomersPage extends StatelessWidget {
  const LoyalCustomersPage({super.key});

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
          'Sodiq mijozlar',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          if (state.status.isFirstLoad) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final ranked = state.customers.where((c) => c.totalSpent > 0).toList()
            ..sort((a, b) => b.totalSpent.compareTo(a.totalSpent));

          if (ranked.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  "Hali biror mijoz nomiga savdo yozilmagan.\n"
                  "To'lov ekranida mijozni biriktirsangiz, uning xaridlari "
                  "shu yerda yig'iladi.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.sage),
                ),
              ),
            );
          }

          final total = ranked.fold<double>(0, (sum, c) => sum + c.totalSpent);

          return ListView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            children: [
              _SummaryCard(count: ranked.length, total: total),
              const SizedBox(height: 16),
              for (var index = 0; index < ranked.length; index++)
                _LoyalCustomerTile(
                  position: index + 1,
                  customer: ranked[index],
                  share: total == 0 ? 0 : ranked[index].totalSpent / total,
                ),
              const SizedBox(height: 12),
              const Text(
                "Foiz — mijozning shu ro'yxatdagi umumiy xariddan ulushi.",
                style: TextStyle(color: AppColors.sage, fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int count;
  final double total;

  const _SummaryCard({required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            "$count ta xarid qilgan mijoz",
            style: const TextStyle(color: AppColors.sage, fontSize: 13),
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
            "Ular jami sarflagan summa",
            style: TextStyle(color: AppColors.sage, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _LoyalCustomerTile extends StatelessWidget {
  final int position;
  final CustomerModel customer;
  final double share;

  const _LoyalCustomerTile({
    required this.position,
    required this.customer,
    required this.share,
  });

  /// Birinchi uchtasi ajratib ko'rsatiladi — qolganlari oddiy tartib raqami.
  Color get _badgeColor => switch (position) {
    1 => const Color(0xFFD4AF37),
    2 => const Color(0xFF9E9E9E),
    3 => const Color(0xFFB87333),
    _ => AppColors.mintMedium,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mintLight),
      ),
      child: ListTile(
        onTap: () => context.push(
          PlatformRoutes.customerdetailsPage.route,
          extra: customer,
        ),
        leading: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _badgeColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: _badgeColor),
          ),
          child: Text(
            '$position',
            style: TextStyle(color: _badgeColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          customer.name,
          style: const TextStyle(
            color: AppColors.forestDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          customer.phone.isEmpty ? "Raqam kiritilmagan" : customer.phone,
          style: const TextStyle(color: AppColors.sage, fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppFormat.money(customer.totalSpent),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${(share * 100).toStringAsFixed(share >= 0.1 ? 0 : 1)}%",
              style: const TextStyle(color: AppColors.sage, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
