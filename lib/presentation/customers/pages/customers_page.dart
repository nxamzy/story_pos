import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_bloc.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_event.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_state.dart';
import 'package:ocam_pos/presentation/customers/widgets/customer_tile.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>()
      ..add(const LoadCustomersEvent())
      // Qidiruv maydoni bo'sh holda ochiladi — filtrni ham tozalaymiz,
      // aks holda ro'yxat oldingi so'rov bo'yicha filtrlangan qolardi.
      ..add(const SearchCustomerEvent(''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Mijozlar',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [_buildAddMenu(context), const SizedBox(width: 10)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) =>
                  context.read<CustomerBloc>().add(SearchCustomerEvent(value)),
              decoration: InputDecoration(
                hintText: "Ism yoki telefon bo'yicha qidirish...",
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 📜 Mijozlar ro'yxati
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state.status.isFirstLoad && state.customers.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final results = state.visibleCustomers;
                if (results.isEmpty) {
                  return const Center(
                    child: Text(
                      "Mijozlar topilmadi",
                      style: TextStyle(color: AppColors.sage),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final customer = results[index];

                    return CustomerTile(
                      name: customer.name,
                      phone: customer.phone,
                      onTap: () {
                        context.push(
                          PlatformRoutes.customerdetailsPage.route,
                          extra: customer,
                        );
                      },
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

  /// Yangi mijoz qo'shish.
  ///
  /// Ilgari bu yerda ikki qatorli menyu bor edi va "Import qilish" faqat
  /// "Tez orada" xabarini chiqarardi. Kontaktlardan import qilish uchun
  /// READ_CONTACTS ruxsati kerak — Google Play uni maxsus asoslash
  /// so'raladigan "nozik ruxsat" deb hisoblaydi. Birinchi reliz uchun
  /// bunga arzimaydi, shuning uchun tugma to'g'ridan-to'g'ri qo'shish
  /// sahifasini ochadi.
  Widget _buildAddMenu(BuildContext context) {
    return IconButton(
      onPressed: () => context.push(PlatformRoutes.addNewCustomerPage.route),
      tooltip: "Yangi mijoz",
      icon: const Icon(
        Icons.add_circle_outline,
        color: AppColors.primary,
        size: 30,
      ),
    );
  }
}
