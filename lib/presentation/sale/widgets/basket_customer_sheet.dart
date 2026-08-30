import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/widgets/base_sheet_wrapper.dart';
import 'package:ocam_pos/data/models/customer_model.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_bloc.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_event.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_state.dart';

/// Sotuvga mijoz biriktirish uchun tanlov ro'yxati.
///
/// Tanlansa shu mijoz obyekti bilan yopiladi (`Navigator.pop(context, customer)`),
/// chaqiruvchi ekran natijani `SelectSaleCustomerEvent` orqali SaleBloc'ga yuboradi.
Future<CustomerModel?> showCustomerSheet(
  BuildContext context, {
  CustomerModel? current,
}) {
  context.read<CustomerBloc>().add(const LoadCustomersEvent());
  return showModalBottomSheet<CustomerModel?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<CustomerBloc>(),
      child: CustomerSelectionSheet(current: current),
    ),
  );
}

class CustomerSelectionSheet extends StatefulWidget {
  final CustomerModel? current;
  const CustomerSelectionSheet({super.key, this.current});

  @override
  State<CustomerSelectionSheet> createState() => _CustomerSelectionSheetState();
}

class _CustomerSelectionSheetState extends State<CustomerSelectionSheet> {
  CustomerModel? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return BaseSheetWrapper(
      title: "Mijozlar",
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                final customers = state.visibleCustomers;
                if (customers.isEmpty) {
                  return const Center(
                    child: Text(
                      "Mijozlar topilmadi",
                      style: TextStyle(color: AppColors.sage),
                    ),
                  );
                }
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return _buildSelectionCard(
                      title: customer.name,
                      subtitle: customer.phone,
                      isSelected: _selected?.id == customer.id,
                      onTap: () => setState(() => _selected = customer),
                    );
                  },
                );
              },
            ),
          ),
          if (_selected != null)
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text(
                "Tanlovni bekor qilish",
                style: TextStyle(color: AppColors.error),
              ),
            ),
          _buildActionBtn("Mijozni tanlash"),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mintLight),
      ),
      child: TextField(
        onChanged: (value) =>
            context.read<CustomerBloc>().add(SearchCustomerEvent(value)),
        decoration: const InputDecoration(
          hintText: "Mijoz ismi bo'yicha qidirish",
          hintStyle: TextStyle(color: AppColors.sage),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.mintLight,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.mintLight,
              radius: 24,
              child: Text(
                title.isNotEmpty ? title[0].toUpperCase() : "?",
                style: const TextStyle(
                  color: AppColors.forestDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.forestDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.sage, fontSize: 13),
                  ),
                ],
              ),
            ),
            _customRadio(isSelected),
          ],
        ),
      ),
    );
  }

  Widget _customRadio(bool isSelected) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.mintMedium,
          width: 2,
        ),
      ),
      child: isSelected
          ? const Center(
              child: CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: 6,
              ),
            )
          : null,
    );
  }

  Widget _buildActionBtn(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: _selected == null
              ? null
              : () => Navigator.pop(context, _selected),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
