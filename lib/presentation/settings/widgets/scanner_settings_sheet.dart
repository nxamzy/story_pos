import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_bloc.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_bloc.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_event.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_state.dart';
import 'package:ocam_pos/presentation/sale/pages/scanner_page.dart';
import 'package:ocam_pos/presentation/settings/widgets/settings_sheet_frame.dart';

/// Shtrix-kod skaneri sozlamalari: tebranish va skanerni sinash.
///
/// Sinash tugmasi kamerani ochadi va o'qilgan kod bo'yicha omborda
/// mahsulot bor-yo'qligini aytadi — do'konni sozlayotganda skaner
/// ishlayotganini savdo qilmasdan tekshirish uchun.
void showScannerSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<ProfileBloc>()),
        BlocProvider.value(value: context.read<ProductBloc>()),
      ],
      child: const _ScannerSettingsSheet(),
    ),
  );
}

class _ScannerSettingsSheet extends StatefulWidget {
  const _ScannerSettingsSheet();

  @override
  State<_ScannerSettingsSheet> createState() => _ScannerSettingsSheetState();
}

class _ScannerSettingsSheetState extends State<_ScannerSettingsSheet> {
  /// Oxirgi sinovda o'qilgan kod haqidagi xabar. `null` — hali sinalmagan.
  String? _testResult;
  bool _testFound = false;

  Future<void> _runTest() async {
    final code = await openBarcodeScanner(context);
    if (code == null || !mounted) return;

    final products = context.read<ProductBloc>().state.products;
    final match = products.where((p) => p.barcode == code).firstOrNull;

    setState(() {
      _testFound = match != null;
      _testResult = match != null
          ? "$code — \"${match.name}\" topildi"
          : "$code — bu kod bilan mahsulot yo'q";
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final haptics = state.user?.scannerHaptics ?? true;

        return SettingsSheetFrame(
          title: "Shtrix-kod skaneri",
          subtitle: "Kamera skaneri qanday ishlashini sozlang",
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mintLight),
                ),
                child: SwitchListTile(
                  value: haptics,
                  activeThumbColor: AppColors.primary,
                  onChanged: (value) => context.read<ProfileBloc>().add(
                    UpdateStoreInfo(scannerHaptics: value),
                  ),
                  title: const Text(
                    "Skanerlanganda tebranish",
                    style: TextStyle(
                      color: AppColors.forestDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: const Text(
                    "Kod o'qilganini qo'lda his qilasiz",
                    style: TextStyle(color: AppColors.sage, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _runTest,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text("Skanerni sinash"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              if (_testResult != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (_testFound ? AppColors.primary : AppColors.error)
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _testFound
                            ? Icons.check_circle_outline
                            : Icons.info_outline,
                        color: _testFound
                            ? AppColors.primary
                            : AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _testResult!,
                          style: const TextStyle(
                            color: AppColors.forestDark,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
