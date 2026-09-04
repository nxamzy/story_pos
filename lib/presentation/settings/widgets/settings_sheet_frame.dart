import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

/// Bitta sozlamani o'zgartirish uchun ixcham pastki varaq.
///
/// `BaseSheetWrapper` ekran balandligining 85% ini egallaydi — bir-ikki
/// qatorli sozlama uchun bu juda katta, shuning uchun bu varaq mazmuniga
/// qarab cho'ziladi.
class SettingsSheetFrame extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const SettingsSheetFrame({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.mintMedium,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.forestDark,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: const TextStyle(fontSize: 13, color: AppColors.sage),
              ),
            ],
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

/// Ro'yxatdan bitta variantni tanlash qatori.
///
/// `RadioListTile` ishlatilmaydi: uning `groupValue`/`onChanged` juftligi
/// Flutter 3.32'dan boshlab eskirgan deb belgilangan, ilova esa nol
/// ogohlantirish bilan tahlildan o'tishi kerak.
class SettingsChoiceTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const SettingsChoiceTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.mintLight : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.mintLight,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.forestDark,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                style: const TextStyle(color: AppColors.sage, fontSize: 12),
              ),
        trailing: Icon(
          selected ? Icons.check_circle : Icons.circle_outlined,
          color: selected ? AppColors.primary : AppColors.mintMedium,
        ),
      ),
    );
  }
}
