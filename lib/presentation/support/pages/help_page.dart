import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/app_config.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';

/// Yordam markazi.
///
/// Aloqa tugmalari `AppConfig`dagi qiymatlar to'ldirilgan bo'lsagina
/// chiziladi — bo'sh qo'llab-quvvatlash kanaliga olib boradigan
/// ishlamaydigan tugma ko'rsatilmaydi.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  static bool get _hasContacts =>
      AppConfig.supportPhone.isNotEmpty ||
      AppConfig.supportEmail.isNotEmpty ||
      AppConfig.supportTelegram.isNotEmpty;

  Future<void> _open(BuildContext context, Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        AppSnackBar.error(context, "Ilova ochilmadi");
      }
    }
  }

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
          'Yordam markazi',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          const _SectionTitle("Tez yechim"),
          _HelpTile(
            icon: Icons.help_outline,
            title: "Ko'p so'raladigan savollar",
            subtitle: "Savdo, qaytarish, kassa va hisobot bo'yicha javoblar",
            onTap: () => context.push(PlatformRoutes.faqPage.route),
          ),
          _HelpTile(
            icon: Icons.settings_outlined,
            title: "Printer yoki skaner ishlamayapti",
            subtitle: "Sozlamalardan qog'oz o'lchamini tanlang, skanerni sinang",
            onTap: () => context.push(PlatformRoutes.settingsPage.route),
          ),
          _HelpTile(
            icon: Icons.receipt_long_outlined,
            title: "Eski chekni topish",
            subtitle: "Sana oralig'i, mijoz yoki chek raqami bo'yicha qidirish",
            onTap: () => context.push(PlatformRoutes.salesHistoryPage.route),
          ),
          _HelpTile(
            icon: Icons.assignment_return_outlined,
            title: "Savdoni qaytarish",
            subtitle: "Qoldiq tiklanadi, naqd pul kassadan qaytariladi",
            onTap: () => context.push(PlatformRoutes.refundsPage.route),
          ),

          if (_hasContacts) ...[
            const _SectionTitle("Bog'lanish"),
            if (AppConfig.supportPhone.isNotEmpty)
              _HelpTile(
                icon: Icons.phone_outlined,
                title: "Qo'ng'iroq qilish",
                subtitle: AppConfig.supportPhone,
                onTap: () => _open(
                  context,
                  Uri(scheme: 'tel', path: AppConfig.supportPhone),
                ),
              ),
            if (AppConfig.supportTelegram.isNotEmpty)
              _HelpTile(
                icon: Icons.send_outlined,
                title: "Telegram orqali yozish",
                subtitle: AppConfig.supportTelegram,
                onTap: () => _open(
                  context,
                  Uri.parse("https://t.me/${AppConfig.supportTelegram}"),
                ),
              ),
            if (AppConfig.supportEmail.isNotEmpty)
              _HelpTile(
                icon: Icons.mail_outline,
                title: "Email yuborish",
                subtitle: AppConfig.supportEmail,
                onTap: () => _open(
                  context,
                  Uri(scheme: 'mailto', path: AppConfig.supportEmail),
                ),
              ),
          ],

          const _SectionTitle("Ilova haqida"),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.mintLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.storefront_outlined,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Ocam POS",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.forestDark,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "v${AppConfig.appVersion}",
                      style: const TextStyle(
                        color: AppColors.sage,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Do'kon ma'lumoti sizning hisobingizga bog'langan holda "
                  "serverda saqlanadi va faqat siz kirgan qurilmadan "
                  "ko'rinadi. Hisobni o'chirsangiz ma'lumot ham butunlay "
                  "o'chadi.",
                  style: TextStyle(
                    color: AppColors.sage,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 12, bottom: 10),
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
}

class _HelpTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HelpTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

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
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.mintLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.forestDark,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.sage, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.sage,
          size: 20,
        ),
      ),
    );
  }
}
