import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/presentation/widgets/home_widget/promo_card_widget.dart';
import 'package:ocam_pos/routes/platform_routes.dart';

import 'menu_grid_widget.dart';

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
          // Reklama Cartasi
          InkWell(
            onTap: () {
              context.push(PlatformRoutes.test.route);
            },
            child: PromoCard(),
          ),
          SizedBox(height: 16),
          // Functionlar
          MenuGrid(),
        ],
      ),
    ),
  );
}
