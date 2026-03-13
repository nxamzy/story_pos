import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/data/models/supplier_model.dart';
import 'package:ocam_pos/presentation/widgets/supplier_widget/detail/detail_info_item.dart';
import './delete_supplier.dart';
import './edit_supplier.dart';

class SupplierDetailsScreen extends StatelessWidget {
  final SupplierModel supplier;

  const SupplierDetailsScreen({super.key, required this.supplier});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Supplier Details',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.primary),
            onPressed: () => showDeleteSupplier(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Hero(
                tag: supplier.id,
                child: Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.mintLight, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(15),
                  child: supplier.imageUrl.isNotEmpty
                      ? Image.network(
                          supplier.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.business,
                                size: 50,
                                color: AppColors.sage,
                              ),
                        )
                      : const Icon(
                          Icons.business,
                          size: 50,
                          color: AppColors.sage,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.mintLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _quickAction(Icons.phone_outlined, "Phone", () {}),
                  _divider(),
                  _quickAction(Icons.email_outlined, "Email", () {}),
                  _divider(),
                  _quickAction(Icons.textsms_outlined, "SMS", () {}),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.mintLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Supplier Data",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.forestDark,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => showEditSupplierSheet(context),
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        label: const Text(
                          "Edit",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DetailInfoItem(label: "Name", value: supplier.name),
                  DetailInfoItem(label: "Phone Number", value: supplier.phone),
                  DetailInfoItem(
                    label: "Email",
                    value: supplier.email.isEmpty ? "N/A" : supplier.email,
                  ),
                  DetailInfoItem(
                    label: "Address",
                    value: supplier.address.isEmpty
                        ? "No address provided"
                        : supplier.address,
                  ),
                  DetailInfoItem(
                    label: "Notes",
                    value: supplier.notes.isEmpty ? "No notes" : supplier.notes,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildInvoicesSection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.forestMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(height: 40, width: 1, color: AppColors.background);

  Widget _buildInvoicesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mintLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Purchases Invoices",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestDark,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  "See All",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _invoiceTile("Invoice #8421", "20/09/2023", "1,280 EGP"),
          _invoiceTile("Invoice #8410", "15/09/2023", "950 EGP"),
        ],
      ),
    );
  }

  Widget _invoiceTile(String title, String date, String amount) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.mintLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.receipt_long,
          color: AppColors.primary,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.forestDark,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        date,
        style: const TextStyle(fontSize: 12, color: AppColors.sage),
      ),
      trailing: Text(
        amount,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
