import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/presentation/sale/bloc/sale_bloc.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';

/// Yakunlangan savdoni ko'rsatadi. `SaleBloc.state.completedSale` dan
/// o'qiydi — chunki savat tozalangandan keyin ham shu ma'lumot state'da qoladi.
void showSuccessSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<SaleBloc>(),
      child: const SuccessSheet(),
    ),
  );
}

class SuccessSheet extends StatelessWidget {
  const SuccessSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final sale = context.watch<SaleBloc>().state.completedSale;
    final total = sale?.total ?? 0;
    final paymentLabel = sale?.paymentMethod == 'card'
        ? "Plastik karta"
        : "Naqd pul";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 45,
            height: 5,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.mintMedium,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            size: 100,
            color: AppColors.primary,
          ),
          const SizedBox(height: 20),
          const Text(
            "Savdo muvaffaqiyatli yakunlandi",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.forestDark,
              ),
              children: [
                const TextSpan(text: "JAMI SUMMA "),
                TextSpan(
                  text: AppFormat.money(total),
                  style: const TextStyle(color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "To'lov turi: $paymentLabel",
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.sage,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),

          InkWell(
            onTap: () => context.push(PlatformRoutes.receiptPage.route),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.mintLight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.receipt_long_outlined, color: AppColors.primary),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Chek tafsilotlari",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.forestDark,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.sage, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: () => context.go(PlatformRoutes.salePage.route),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Yangi sotuv",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
