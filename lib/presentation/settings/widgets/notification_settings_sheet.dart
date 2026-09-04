import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/app_config.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_bloc.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_state.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_bloc.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_event.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_state.dart';
import 'package:ocam_pos/presentation/settings/widgets/settings_sheet_frame.dart';

/// Ombor ogohlantirishlari sozlamasi.
///
/// "Kam qoldi" chegarasi ilgari kodda qattiq yozilgan 5 raqami edi;
/// bittalab sotiladigan do'kon bilan qutilab sotiladigan do'kon uchun bu
/// chegara bir xil bo'lishi mumkin emas, shuning uchun endi sozlanadi.
void showNotificationSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<ProfileBloc>()),
        BlocProvider.value(value: context.read<ProductBloc>()),
      ],
      child: const _NotificationSettingsSheet(),
    ),
  );
}

class _NotificationSettingsSheet extends StatelessWidget {
  const _NotificationSettingsSheet();

  static const _min = 1;
  static const _max = 100;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final threshold =
            state.user?.lowStockThreshold ?? AppConfig.defaultLowStockThreshold;

        void change(int delta) {
          final next = (threshold + delta).clamp(_min, _max);
          if (next != threshold) {
            context.read<ProfileBloc>().add(
              UpdateStoreInfo(lowStockThreshold: next),
            );
          }
        }

        return SettingsSheetFrame(
          title: "Bildirishnomalar",
          subtitle: "Ombor qoldig'i haqida qachon ogohlantirilsin",
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mintLight),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          "Kam qoldi chegarasi",
                          style: TextStyle(
                            color: AppColors.forestDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: threshold > _min ? () => change(-1) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.primary,
                    ),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '$threshold',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.forestDark,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: threshold < _max ? () => change(1) : null,
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Qoldig'i $threshold ta yoki undan kam mahsulot "
                "\"Bildirishnomalar\"da ogohlantirish sifatida chiqadi.",
                style: const TextStyle(color: AppColors.sage, fontSize: 12),
              ),
              const SizedBox(height: 16),
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, productState) {
                  final count = productState.lowStockProducts.length;

                  return OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(PlatformRoutes.notificationsPage.route);
                    },
                    icon: const Icon(Icons.notifications_none_outlined),
                    label: Text(
                      count == 0
                          ? "Hozir ogohlantirish yo'q"
                          : "Hozir $count ta mahsulot kam qolgan",
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
