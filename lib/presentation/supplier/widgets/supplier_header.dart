import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

class SupplierHeader extends StatelessWidget {
  const SupplierHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 15, bottom: 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          const Text(
            "Ta'minotchilar",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const Spacer(),
          // Ilgari ikki qatorli menyu edi va "Kontaktlardan import
          // qilish" faqat "Tez orada" xabarini chiqarardi. Kontaktlarga
          // kirish Google Play'da maxsus asoslash talab qiladigan nozik
          // ruxsat — birinchi reliz uchun keraksiz xavf.
          IconButton(
            onPressed: () =>
                context.push(PlatformRoutes.addNewSupplierPage.route),
            tooltip: "Yangi ta'minotchi",
            icon: const Icon(
              Icons.person_add_alt_1_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
