import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/presentation/widgets/basket_widget/base_sheet_wrapper.dart';

void showCustomerSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const CustomerSelectionSheet(),
  );
}

class CustomerSelectionSheet extends StatefulWidget {
  const CustomerSelectionSheet({super.key});

  @override
  State<CustomerSelectionSheet> createState() => _CustomerSelectionSheetState();
}

class _CustomerSelectionSheetState extends State<CustomerSelectionSheet> {
  int _selectedId = 0;

  @override
  Widget build(BuildContext context) {
    return BaseSheetWrapper(
      title: "Customers",
      showAddBtn: true,
      onAddTap: () {},
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: 8,
              itemBuilder: (context, index) => _buildSelectionCard(
                title: "Customer Name $index",
                subtitle: "01033970808",
                isCustomer: true,
                isSelected: _selectedId == index,
                onTap: () => setState(() => _selectedId = index),
              ),
            ),
          ),
          _buildActionBtn("Select Customer"),
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
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Search by customer name",
          hintStyle: TextStyle(color: AppColors.sage),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          suffixIcon: Icon(Icons.tune, color: AppColors.forestDark),
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
    bool isCustomer = false,
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
              backgroundImage: isCustomer
                  ? const NetworkImage('https://i.pravatar.cc/150?img=3')
                  : null,
              radius: 24,
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
          onPressed: () => Navigator.pop(context),
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
