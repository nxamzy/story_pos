import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/data/models/customer_model.dart';
import 'package:ocam_pos/presentation/pages/customers/buttom_sheets/card_information.dart';
import 'package:ocam_pos/presentation/pages/customers/buttom_sheets/delete_customer.dart';
import 'package:ocam_pos/presentation/widgets/customer_widget/details_section_card.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerDetailsPage extends StatelessWidget {
  final CustomerModel customer;

  const CustomerDetailsPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
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
          'Customer Details',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.primary),
            onPressed: () => showDeleteConfirmation(
              context, // 🔥 MANA BU ETISHMAYOTGAN EDI!
              customerId: customer.id,
              customerName: customer.name,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _ProfileImage(name: customer.name),
            const SizedBox(height: 12),
            Text(
              customer.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.forestDark,
              ),
            ),
            const SizedBox(height: 24),
            _ContactButtonsRow(phone: customer.phone),
            const SizedBox(height: 24),
            _buildPersonalInfo(context),
            const SizedBox(height: 16),
            _buildFinancialStats(),
            const SizedBox(height: 16),
            _buildSaleInvoices(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo(BuildContext context) {
    return DetailsSectionCard(
      title: "Personal Information",
      trailing: IconButton(
        icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
        onPressed: () {
          showEditPersonalData(context, customer);
        },
      ),
      child: Column(
        children: [
          _InfoRow(label: "Full Name", value: customer.name),
          _InfoRow(label: "Phone Number", value: customer.phone),
          _InfoRow(label: "Registration ID", value: customer.id.toUpperCase()),
          _InfoRow(
            label: "Created Date",
            value:
                "${customer.createdAt.day}/${customer.createdAt.month}/${customer.createdAt.year}",
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialStats() {
    return DetailsSectionCard(
      title: "Financial Overview",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${customer.totalSpent.toStringAsFixed(0)} UZS",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Text(
            "Total Amount Spent",
            style: TextStyle(color: AppColors.sage, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleInvoices() {
    return DetailsSectionCard(
      title: "Recent Sales Invoices",
      trailing: _SeeMoreButton(onTap: () {}),
      child: Column(
        children: const [
          _InvoiceTile(
            date: "No recent transactions",
            price: "0 UZS",
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ProfileImage extends StatelessWidget {
  final String name;
  const _ProfileImage({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.mintLight, width: 2),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : "?",
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _ContactButtonsRow extends StatelessWidget {
  final String phone;
  const _ContactButtonsRow({required this.phone});

  Future<void> _makeCall() async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _sendSMS() async {
    final Uri url = Uri(scheme: 'sms', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionBtn(Icons.phone_outlined, "Call", _makeCall),
        _buildActionBtn(Icons.chat_bubble_outline, "SMS", _sendSMS),
        _buildActionBtn(Icons.share_outlined, "Share", () {}),
      ],
    );
  }

  Widget _buildActionBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.mintLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey50.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.sage,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.sage, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.forestDark,
            ),
          ),
          if (!isLast)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Divider(height: 1, color: AppColors.mintLight),
            ),
        ],
      ),
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  final String date;
  final String price;
  final bool isLast;
  const _InvoiceTile({
    required this.date,
    required this.price,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: AppColors.sage),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestDark,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.sage),
        ],
      ),
    );
  }
}

class _SeeMoreButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SeeMoreButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: const Text(
        "View All >",
        style: TextStyle(color: AppColors.primary, fontSize: 12),
      ),
    );
  }
}
