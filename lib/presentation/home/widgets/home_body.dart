import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';
import 'package:ocam_pos/presentation/home/widgets/promo_card.dart';

import 'package:ocam_pos/presentation/home/widgets/menu_grid.dart';

/// Bosh sahifaning asosiy qismi.
///
/// Diqqat: bu widget `HomeTabContent`da allaqachon `Expanded` ichiga
/// joylashtirilgan — shu sababli bu yerda yana `Expanded` qaytarilmaydi.
/// Ilgari shunday edi va Flutter har build'da "Incorrect use of
/// ParentDataWidget" xatosini chiqarardi (ikkita `Expanded` bitta
/// RenderObject'ga parent data yozardi).
class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        // Reklama kartochkasi savdo ekraniga olib boradi — ilgari bosilganda
        // "Tez orada" xabari chiqardi, holbuki kartochka mobil kassa
        // haqida edi.
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.push(PlatformRoutes.salePage.route),
          child: const PromoCard(),
        ),
        const SizedBox(height: 16),
        const MenuGrid(),
      ],
    ),
  );
}
