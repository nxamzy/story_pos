import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';
import 'package:ocam_pos/presentation/home/widgets/date_card.dart';
import 'package:ocam_pos/presentation/supplier/bloc/supplier_bloc.dart';
import 'package:ocam_pos/presentation/supplier/bloc/supplier_event.dart';
import 'package:ocam_pos/presentation/supplier/bloc/supplier_state.dart';
import 'package:ocam_pos/presentation/supplier/widgets/supplier_card.dart';
import 'package:ocam_pos/presentation/supplier/widgets/supplier_header.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SupplierBloc>().add(const LoadSuppliers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<SupplierBloc, SupplierState>(
        listenWhen: (previous, current) => current.error != previous.error,
        listener: (context, state) {
          if (state.error != null) {
            AppSnackBar.error(context, state.error!);
          }
        },
        child: Column(
          children: [
            const SupplierHeader(),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: BlocBuilder<SupplierBloc, SupplierState>(
                buildWhen: (p, c) => p.filterDate != c.filterDate,
                builder: (context, state) => Row(
                  children: [
                    DataCard(
                      initialDate: state.filterDate,
                      onDateSelected: (date) => context
                          .read<SupplierBloc>()
                          .add(LoadSuppliers(date: date)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.mintLight),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.forestDark.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => context
                              .read<SupplierBloc>()
                              .add(SearchSuppliers(value)),
                          decoration: const InputDecoration(
                            hintText: 'Qidirish...',
                            hintStyle: TextStyle(
                              color: AppColors.sage,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: BlocBuilder<SupplierBloc, SupplierState>(
                builder: (context, state) {
                  if (state.status.isFirstLoad && state.suppliers.isEmpty) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  final filtered = state.visibleSuppliers;

                  if (filtered.isEmpty) {
                    return _buildEmptyState(state.filterDate);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return SupplierCard(supplier: filtered[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(DateTime? selectedDate) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Icon(
              Icons.person_search_outlined,
              size: 80,
              color: AppColors.sage.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              "Ta'minotchi topilmadi",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.forestDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedDate == null
                  ? "Hozircha hech qanday ma'lumot yo'q."
                  : "Ushbu sanada ma'lumotlar mavjud emas.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.sage),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  context.push(PlatformRoutes.addNewSupplierPage.route),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                "Yangi qo'shish",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
