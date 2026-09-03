import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/core/widgets/app_state_views.dart';
import 'package:ocam_pos/data/models/purchase_model.dart';
import 'package:ocam_pos/presentation/purchases/bloc/purchase_bloc.dart';
import 'package:ocam_pos/presentation/purchases/bloc/purchase_event.dart';
import 'package:ocam_pos/presentation/purchases/bloc/purchase_state.dart';

/// Ta'minotchilardan qilingan xaridlar tarixi.
class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});

  @override
  State<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  @override
  void initState() {
    super.initState();
    context.read<PurchaseBloc>().add(const LoadPurchases());
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
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: const Text(
          "Xaridlar",
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => context.push(PlatformRoutes.addPurchasePage.route),
        icon: const Icon(Icons.add),
        label: const Text("Xarid"),
      ),
      body: BlocBuilder<PurchaseBloc, PurchaseState>(
        builder: (context, state) {
          if (state.status.isFirstLoad && state.purchases.isEmpty) {
            return const AppLoader();
          }

          if (state.status.isFailure && state.purchases.isEmpty) {
            return AppErrorView(
              message: state.error ?? "Xaridlarni yuklab bo'lmadi",
              onRetry: () =>
                  context.read<PurchaseBloc>().add(const LoadPurchases()),
            );
          }

          if (state.purchases.isEmpty) {
            return const AppEmptyView(
              icon: Icons.local_shipping_outlined,
              message:
                  "Hozircha xarid yozilmagan.\nTa'minotchidan kelgan tovarni "
                  "shu yerda omborga kiritasiz.",
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
            physics: const BouncingScrollPhysics(),
            itemCount: state.purchases.length,
            itemBuilder: (context, index) =>
                _PurchaseTile(purchase: state.purchases[index]),
          );
        },
      ),
    );
  }
}

class _PurchaseTile extends StatelessWidget {
  final PurchaseModel purchase;

  const _PurchaseTile({required this.purchase});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mintLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.mintLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      purchase.supplierName.isEmpty
                          ? "Ta'minotchi ko'rsatilmagan"
                          : purchase.supplierName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.forestDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${AppFormat.dateTime(purchase.createdAt)} · "
                      "${purchase.itemCount} dona"
                      "${purchase.paidFromDrawer ? ' · Kassadan' : ' · Qarzga'}",
                      style: const TextStyle(
                        color: AppColors.sage,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                AppFormat.money(purchase.total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.mintLight),
          for (final item in purchase.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${item.name} x${item.quantity}",
                      style: const TextStyle(
                        color: AppColors.forestDark,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    AppFormat.money(item.subTotal),
                    style: const TextStyle(
                      color: AppColors.sage,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          if (purchase.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              purchase.note,
              style: const TextStyle(
                color: AppColors.mintMedium,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
