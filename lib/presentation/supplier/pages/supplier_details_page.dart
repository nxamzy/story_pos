import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/data/models/supplier_model.dart';
import 'package:ocam_pos/presentation/supplier/widgets/detail_info_item.dart';
import 'package:ocam_pos/presentation/supplier/widgets/delete_supplier_sheet.dart';
import 'package:ocam_pos/presentation/supplier/pages/edit_supplier_page.dart';

class SupplierDetailsScreen extends StatelessWidget {
  final SupplierModel supplier;

  const SupplierDetailsScreen({super.key, required this.supplier});

  Future<void> _launch(BuildContext context, Uri uri) async {
    final ok = await canLaunchUrl(uri);
    if (!ok) {
      if (context.mounted) {
        AppSnackBar.error(context, "Bu amalni bajarib bo'lmadi");
      }
      return;
    }
    await launchUrl(uri);
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
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Ta'minotchi tafsiloti",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.primary),
            onPressed: () => showDeleteSupplier(context, supplier.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Hero(
                tag: supplier.id,
                child: Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.mintLight, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(15),
                  child: supplier.imageUrl.isNotEmpty
                      ? Image.network(
                          supplier.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.business,
                                size: 50,
                                color: AppColors.sage,
                              ),
                        )
                      : const Icon(
                          Icons.business,
                          size: 50,
                          color: AppColors.sage,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.mintLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _quickAction(
                    Icons.phone_outlined,
                    "Qo'ng'iroq",
                    supplier.phone.isEmpty
                        ? null
                        : () => _launch(context, Uri.parse('tel:${supplier.phone}')),
                  ),
                  _divider(),
                  _quickAction(
                    Icons.email_outlined,
                    "Email",
                    supplier.email.isEmpty
                        ? null
                        : () => _launch(context, Uri.parse('mailto:${supplier.email}')),
                  ),
                  _divider(),
                  _quickAction(
                    Icons.textsms_outlined,
                    "SMS",
                    supplier.phone.isEmpty
                        ? null
                        : () => _launch(context, Uri.parse('sms:${supplier.phone}')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.mintLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Ta'minotchi ma'lumoti",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.forestDark,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => showEditSupplierSheet(context, supplier),
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        label: const Text(
                          "Tahrirlash",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DetailInfoItem(label: "Nomi", value: supplier.name),
                  DetailInfoItem(label: "Telefon raqami", value: supplier.phone),
                  DetailInfoItem(
                    label: "Email",
                    value: supplier.email.isEmpty ? "Kiritilmagan" : supplier.email,
                  ),
                  DetailInfoItem(
                    label: "Manzil",
                    value: supplier.address.isEmpty
                        ? "Manzil kiritilmagan"
                        : supplier.address,
                  ),
                  DetailInfoItem(
                    label: "Eslatma",
                    value: supplier.notes.isEmpty ? "Eslatma yo'q" : supplier.notes,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback? onTap) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.forestMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      Container(height: 40, width: 1, color: AppColors.background);
}
