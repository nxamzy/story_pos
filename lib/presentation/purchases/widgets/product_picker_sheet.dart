import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/core/widgets/base_sheet_wrapper.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_bloc.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_state.dart';

/// Ombordagi mahsulotlardan bittasini tanlash.
///
/// Qidiruv shu varaqning o'z holatida — `ProductBloc`dagi filtrga tegmaydi,
/// aks holda Ombor sahifasidagi ro'yxat ham filtrlanib qolardi.
Future<ProductModel?> showProductPickerSheet(BuildContext context) {
  return showModalBottomSheet<ProductModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<ProductBloc>(),
      child: const _ProductPickerSheet(),
    ),
  );
}

class _ProductPickerSheet extends StatefulWidget {
  const _ProductPickerSheet();

  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return BaseSheetWrapper(
      title: "Mahsulot tanlash",
      child: Column(
        children: [
          TextField(
            autofocus: true,
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              hintText: "Nomi yoki shtrix-kod bo'yicha qidirish",
              prefixIcon: Icon(Icons.search, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                final query = _query.trim().toLowerCase();
                final products = query.isEmpty
                    ? state.products
                    : state.products
                          .where(
                            (p) =>
                                p.name.toLowerCase().contains(query) ||
                                p.barcode.toLowerCase().contains(query),
                          )
                          .toList();

                if (products.isEmpty) {
                  return const Center(
                    child: Text(
                      "Mahsulot topilmadi",
                      style: TextStyle(color: AppColors.sage),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.mintLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.forestDark,
                        ),
                      ),
                      subtitle: Text(
                        "Qoldiq: ${product.stock} dona · Tannarx: "
                        "${AppFormat.money(product.buyPrice)}",
                        style: const TextStyle(
                          color: AppColors.sage,
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primary,
                      ),
                      onTap: () => Navigator.pop(context, product),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
