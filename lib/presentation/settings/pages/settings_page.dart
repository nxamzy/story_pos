import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/app_config.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/core/widgets/confirm_dialog.dart';
import 'package:ocam_pos/core/widgets/text_input_dialog.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';
import 'package:ocam_pos/data/models/user_model.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_bloc.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_event.dart';
import 'package:ocam_pos/presentation/auth/bloc/auth_state.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_bloc.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_event.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_state.dart';
import 'package:ocam_pos/core/utils/receipt_paper.dart';
import 'package:ocam_pos/presentation/settings/widgets/notification_settings_sheet.dart';
import 'package:ocam_pos/presentation/settings/widgets/printer_settings_sheet.dart';
import 'package:ocam_pos/presentation/settings/widgets/scanner_settings_sheet.dart';
import 'package:ocam_pos/presentation/settings/widgets/settings_item.dart';
import 'package:ocam_pos/presentation/settings/widgets/time_format_sheet.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
          'Sozlamalar',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: AppColors.mintLight),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProfileBloc, ProfileState>(
            listenWhen: (previous, current) =>
                current.actionMessage != null || current.error != null,
            listener: (context, state) {
              if (state.error != null) {
                AppSnackBar.error(context, state.error!);
              } else if (state.actionMessage != null) {
                AppSnackBar.success(context, state.actionMessage!);
              }
            },
          ),
          // Hisobni o'chirish xatosi (masalan noto'g'ri parol) shu yerda
          // ko'rsatiladi; muvaffaqiyat bo'lsa sessiya tugab, router o'zi
          // login sahifasiga qaytaradi.
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) => current.hasError,
            listener: (context, state) =>
                AppSnackBar.error(context, state.errorMessage!),
          ),
        ],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Do'kon ma'lumoti"),
              const _StoreInfoSection(),

              _buildSectionTitle("Kassa sozlamalari"),
              const _CurrencySetting(),

              _buildSectionTitle("Qurilma sozlamalari"),
              const _DeviceSettingsSection(),

              _buildSectionTitle("Umumiy sozlamalar"),
              const _GeneralSettingsSection(),
              SettingsItem(
                title: "Parolni o'zgartirish",
                icon: Icons.lock_outline,
                onTap: () => context.push(PlatformRoutes.chanegePassword.route),
              ),

              const SizedBox(height: 20),
              _buildLogoutButton(context),

              _buildSectionTitle("Xavfli hudud"),
              const _DeleteAccountTile(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.sage,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        onTap: () async {
          final confirmed = await showConfirmDialog(
            context,
            title: "Chiqish",
            message: "Hisobingizdan chiqishni istaysizmi?",
            confirmLabel: "Ha, chiqish",
          );
          if (confirmed && context.mounted) {
            context.read<AuthBloc>().add(const SignOutRequested());
          }
        },
        leading: const Icon(Icons.logout, color: AppColors.error),
        title: const Text(
          "Chiqish",
          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// Printer va shtrix-kod skaneri sozlamalari.
///
/// Ikkalasi ham ilgari "Tez orada" xabarini chiqarardi, holbuki chek 80 mm
/// lentaga qattiq bog'langan va skaner har doim tebranadigan edi.
class _DeviceSettingsSection extends StatelessWidget {
  const _DeviceSettingsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final user = state.user;

        return Column(
          children: [
            SettingsItem(
              title: "Printer",
              icon: Icons.print_outlined,
              value: (user?.receiptPaper ?? ReceiptPaper.roll80).label,
              onTap: () => showPrinterSettingsSheet(context),
            ),
            SettingsItem(
              title: "Shtrix-kod skaneri",
              icon: Icons.qr_code_scanner_outlined,
              value: (user?.scannerHaptics ?? true)
                  ? "Tebranish yoqilgan"
                  : "Tebranish o'chirilgan",
              onTap: () => showScannerSettingsSheet(context),
            ),
          ],
        );
      },
    );
  }
}

/// Ombor ogohlantirishi chegarasi va vaqt formati.
class _GeneralSettingsSection extends StatelessWidget {
  const _GeneralSettingsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final user = state.user;
        final threshold =
            user?.lowStockThreshold ?? AppConfig.defaultLowStockThreshold;

        return Column(
          children: [
            SettingsItem(
              title: "Bildirishnomalar",
              icon: Icons.notifications_none_outlined,
              value: "Kam qoldi chegarasi: $threshold ta",
              onTap: () => showNotificationSettingsSheet(context),
            ),
            SettingsItem(
              title: "Vaqt formati",
              icon: Icons.access_time,
              value: (user?.use24HourFormat ?? true)
                  ? "24 soatlik"
                  : "12 soatlik",
              onTap: () => showTimeFormatSheet(context),
            ),
          ],
        );
      },
    );
  }
}

/// Do'kon ma'lumotlari: nomi, aloqa raqami, STIR va manzil.
///
/// Bu to'rt sozlama ilgari faqat "Tez orada" xabarini ko'rsatardi, holbuki
/// `UserModel`da ular uchun joy bor edi. Endi haqiqatan saqlanadi va chekda
/// chop etiladi.
class _StoreInfoSection extends StatelessWidget {
  const _StoreInfoSection();

  Future<void> _edit(
    BuildContext context, {
    required String title,
    required String current,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required UpdateStoreInfo Function(String value) toEvent,
  }) async {
    final value = await showTextInputDialog(
      context,
      title: title,
      initialValue: current,
      hint: hint,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
    if (value == null || !context.mounted || value == current) return;

    context.read<ProfileBloc>().add(toEvent(value));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final user = state.user ?? const UserModel(uid: '', email: '');

        return Column(
          children: [
            SettingsItem(
              title: "Do'kon nomi",
              icon: Icons.store_outlined,
              value: user.storeName,
              onTap: () => _edit(
                context,
                title: "Do'kon nomi",
                current: user.storeName,
                hint: "masalan: Ocam Market",
                toEvent: (value) => UpdateStoreInfo(storeName: value),
              ),
            ),
            SettingsItem(
              title: "Aloqa raqami",
              icon: Icons.phone_in_talk_outlined,
              value: user.storePhone,
              onTap: () => _edit(
                context,
                title: "Aloqa raqami",
                current: user.storePhone,
                hint: "+998 90 123 45 67",
                keyboardType: TextInputType.phone,
                toEvent: (value) => UpdateStoreInfo(storePhone: value),
              ),
            ),
            SettingsItem(
              title: "STIR",
              icon: Icons.assignment_outlined,
              value: user.taxId,
              onTap: () => _edit(
                context,
                title: "STIR",
                current: user.taxId,
                hint: "9 xonali raqam",
                keyboardType: TextInputType.number,
                toEvent: (value) => UpdateStoreInfo(taxId: value),
              ),
            ),
            SettingsItem(
              title: "Manzil",
              icon: Icons.location_on_outlined,
              value: user.address,
              onTap: () => _edit(
                context,
                title: "Manzil",
                current: user.address,
                hint: "Shahar, ko'cha, uy",
                maxLines: 2,
                toEvent: (value) => UpdateStoreInfo(address: value),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Do'kon valyutasi. Butun ilovadagi narxlar shu belgida ko'rsatiladi.
class _CurrencySetting extends StatelessWidget {
  const _CurrencySetting();

  /// Ko'p ishlatiladigan valyutalar; ro'yxatda yo'q bo'lsa qo'lda kiritsa
  /// ham bo'ladi.
  static const _suggestions = ['UZS', 'USD', 'EUR', 'RUB'];

  Future<void> _edit(BuildContext context, String current) async {
    final value = await showTextInputDialog(
      context,
      title: "Valyuta",
      initialValue: current,
      hint: "masalan: ${_suggestions.join(', ')}",
    );
    if (value == null || !context.mounted) return;

    final currency = value.trim().toUpperCase();
    if (currency.isEmpty || currency == current) return;

    context.read<ProfileBloc>().add(UpdateStoreInfo(currency: currency));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final currency = state.user?.currency ?? AppConfig.defaultCurrency;

        return SettingsItem(
          title: "Valyuta",
          icon: Icons.payments_outlined,
          value: currency,
          onTap: () => _edit(context, currency),
        );
      },
    );
  }
}

/// Hisobni va do'konning barcha ma'lumotini butunlay o'chirish.
///
/// Google Play talabi: ro'yxatdan o'tkazadigan ilova hisobni o'chirish
/// imkonini ham berishi shart. Amal ortga qaytmaydi, shuning uchun avval
/// nima o'chishi aytiladi, keyin parol qayta so'raladi.
class _DeleteAccountTile extends StatelessWidget {
  const _DeleteAccountTile();

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: "Hisobni butunlay o'chirish",
      message:
          "Hisobingiz va u bilan birga barcha mahsulot, savdo, mijoz, "
          "ta'minotchi, xodim, xarajat, xarid hamda kassa ma'lumoti "
          "serverdan butunlay o'chiriladi.\n\n"
          "Bu amalni ortga qaytarib bo'lmaydi.",
      confirmLabel: "Ha, o'chirish",
    );
    if (!confirmed || !context.mounted) return;

    final password = await showTextInputDialog(
      context,
      title: "Parolni tasdiqlang",
      hint: "Hisob paroli",
      obscureText: true,
      saveLabel: "O'chirish",
    );
    if (password == null || password.isEmpty || !context.mounted) return;

    context.read<AuthBloc>().add(AccountDeletionRequested(password));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) => previous.isLoading != current.isLoading,
      builder: (context, state) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
          ),
          child: ListTile(
            onTap: state.isLoading ? null : () => _delete(context),
            leading: state.isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.error,
                    ),
                  )
                : const Icon(Icons.delete_forever, color: AppColors.error),
            title: const Text(
              "Hisobni butunlay o'chirish",
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              "Do'konning barcha ma'lumoti bilan birga",
              style: TextStyle(color: AppColors.sage, fontSize: 12),
            ),
          ),
        );
      },
    );
  }
}
