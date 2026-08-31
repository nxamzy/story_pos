import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_bloc.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_state.dart';
import 'package:ocam_pos/presentation/notifications/widgets/notification_card.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bildirishnomalar',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: ColoredBox(color: AppColors.mintLight, child: SizedBox(height: 1.0)),
        ),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          final lowStock = state.lowStockProducts;

          return ListView(
            padding: const EdgeInsets.all(20.0),
            physics: const BouncingScrollPhysics(),
            children: [
              const Text(
                'Yangiliklardan xabardor bo\'ling',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Mahsulot qoldig'i tugab qolganda sizga xabar beriladi",
                style: TextStyle(fontSize: 14, color: AppColors.sage),
              ),
              const SizedBox(height: 32),

              const Text(
                "Ombor haqida ogohlantirish",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),

              if (lowStock.isEmpty)
                const Text(
                  "Hozircha kam qolgan mahsulot yo'q",
                  style: TextStyle(color: AppColors.sage),
                )
              else
                ...lowStock.map(
                  (product) => NotificationCard(
                    title: "Ombor ogohlantiruvi",
                    subtitle: product.category ?? '',
                    message: product.isOutOfStock
                        ? "\"${product.name}\" omborda tugagan!"
                        : "\"${product.name}\" dan omborda faqat "
                              "${product.stock} ta qoldi!",
                    isHighlighted: true,
                    icon: Icons.warning_amber_rounded,
                    onTap: () =>
                        context.push(PlatformRoutes.inventoryPage.route),
                  ),
                ),

              const SizedBox(height: 32),

              const Text(
                'Boshqa xabarlar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestDark,
                ),
              ),
              const SizedBox(height: 12),

              NotificationCard(
                title: "Ombor tannarxi",
                subtitle: "Umumiy",
                message: "Ombordagi mahsulotlaringizni to'liq ko'rish uchun "
                    "\"Ombor\" bo'limiga o'ting.",
                icon: Icons.inventory_2_outlined,
                onTap: () => context.push(PlatformRoutes.inventoryPage.route),
              ),
            ],
          );
        },
      ),
    );
  }
}
