import 'package:flutter/material.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/presentation/home/widgets/promo_card.dart';

import 'package:ocam_pos/presentation/home/widgets/menu_grid.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) => Expanded(
    child: SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          InkWell(
            onTap: () =>
                AppSnackBar.info(context, "Tez orada qo'shiladi"),
            child: const PromoCard(),
          ),
          SizedBox(height: 16),
          MenuGrid(),
        ],
      ),
    ),
  );
}
