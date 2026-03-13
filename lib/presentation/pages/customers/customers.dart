import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/presentation/pages/customers/bloc/customer_bloc.dart';
import 'package:ocam_pos/presentation/widgets/customer_widget/customer_tile.dart';
import 'package:ocam_pos/routes/platform_routes.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  @override
  void initState() {
    super.initState();
    // Sahifa ochilishi bilan yuklaymiz
    context.read<CustomerBloc>().add(LoadCustomersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Customers',
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
          // 🔍 Qidiruv paneli
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) =>
                  context.read<CustomerBloc>().add(SearchCustomerEvent(value)),
              decoration: InputDecoration(
                hintText: "Search name or phone...",
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
                if (state.isLoading && state.customers.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state.searchResults.isEmpty) {
                  return const Center(
                    child: Text(
                      "No customers found",
                      style: TextStyle(color: AppColors.sage),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.searchResults.length,
                  itemBuilder: (context, index) {
                    final customer =
                        state.searchResults[index]; // 🆔 Tanlangan mijoz

                    return CustomerTile(
                      name: customer.name,
                      phone: customer.phone,
                      onTap: () {
                        // 🔥 MUHIM JOYI:
                        // 'currentCustomer' emas, 'customer'ni uzatamiz!
                        // GoRouter extra orqali butun modelni olib o'tadi
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

  Widget _buildAddMenu(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(
        Icons.add_circle_outline,
        color: AppColors.primary,
        size: 30,
      ),
      onSelected: (value) {
        if (value == 2) {
          context.push(PlatformRoutes.addNewCustomerPage.route);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.contact_phone, color: AppColors.primary),
              SizedBox(width: 8),
              Text("Import"),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(Icons.edit, color: AppColors.primary),
              SizedBox(width: 8),
              Text("Add Manual"),
            ],
          ),
        ),
      ],
    );
  }
}
