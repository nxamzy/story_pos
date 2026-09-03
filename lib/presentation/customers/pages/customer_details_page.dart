import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/data/models/customer_model.dart';
import 'package:ocam_pos/injection.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_sales_bloc.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_sales_event.dart';
import 'package:ocam_pos/presentation/customers/bloc/customer_sales_state.dart';
import 'package:ocam_pos/presentation/customers/widgets/customer_info_sheet.dart';
import 'package:ocam_pos/presentation/customers/widgets/delete_customer_sheet.dart';
import 'package:ocam_pos/presentation/customers/widgets/details_section_card.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerDetailsPage extends StatelessWidget {
  final CustomerModel customer;

  const CustomerDetailsPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CustomerSalesBloc>(
      create: (_) =>
          sl<CustomerSalesBloc>()..add(LoadCustomerSales(customer.id)),
      child: _CustomerDetailsView(customer: customer),
    );
  }
}

class _CustomerDetailsView extends StatelessWidget {
  final CustomerModel customer;

  const _CustomerDetailsView({required this.customer});

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
          'Mijoz tafsiloti',
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
              context,
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
            _buildSaleInvoices(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo(BuildContext context) {
    return DetailsSectionCard(
      title: "Shaxsiy ma'lumot",
      trailing: IconButton(
        icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
        onPressed: () {
          showEditPersonalData(context, customer);
        },
      ),
      child: Column(
        children: [
          _InfoRow(label: "To'liq ism", value: customer.name),
          _InfoRow(label: "Telefon raqami", value: customer.phone),
          if (customer.altPhone.isNotEmpty)
            _InfoRow(label: "Qo'shimcha telefon", value: customer.altPhone),
          if (customer.email.isNotEmpty)
            _InfoRow(label: "Email", value: customer.email),
          if (customer.address.isNotEmpty)
            _InfoRow(label: "Manzil", value: customer.address),
          if (customer.notes.isNotEmpty)
            _InfoRow(label: "Eslatma", value: customer.notes),
          _InfoRow(label: "Ro'yxat ID", value: customer.id.toUpperCase()),
          _InfoRow(
            label: "Ro'yxatdan o'tgan sana",
            value: AppFormat.dateLong(customer.createdAt),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialStats() {
    return DetailsSectionCard(
      title: "Moliyaviy umumiy ko'rinish",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // Valyuta va ming ajratgichlari ilova bo'ylab bir xil bo'lishi
            // uchun qo'lda yozilgan "UZS" o'rniga AppFormat ishlatiladi.
            AppFormat.money(customer.totalSpent),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Text(
            "Jami sarflangan summa",
            style: TextStyle(color: AppColors.sage, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleInvoices(BuildContext context) {
    return BlocBuilder<CustomerSalesBloc, CustomerSalesState>(
      builder: (context, state) {
        return DetailsSectionCard(
          title: "So'nggi xaridlar",
          trailing: _SeeMoreButton(
            onTap: () => AppSnackBar.info(context, "Tez orada qo'shiladi"),
          ),
          child: _buildInvoiceList(state),
        );
      },
    );
  }

  Widget _buildInvoiceList(CustomerSalesState state) {
    if (state.status.isFirstLoad) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    if (state.sales.isEmpty) {
      return const _InvoiceTile(
        date: "Hozircha xaridlar yo'q",
        price: "0 UZS",
        isLast: true,
      );
    }

    const maxShown = 5;
    final shown = state.sales.take(maxShown).toList();

    return Column(
      children: [
        for (int i = 0; i < shown.length; i++)
          _InvoiceTile(
            date: AppFormat.date(shown[i].createdAt),
            price: AppFormat.money(shown[i].total),
            isLast: i == shown.length - 1,
          ),
      ],
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
        color: AppColors.primary.withValues(alpha: 0.1),
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
        _buildActionBtn(Icons.phone_outlined, "Qo'ng'iroq", _makeCall),
        _buildActionBtn(Icons.chat_bubble_outline, "SMS", _sendSMS),
        _buildActionBtn(
          Icons.share_outlined,
          "Ulashish",
          () => AppSnackBar.info(context, "Tez orada qo'shiladi"),
        ),
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
              color: AppColors.grey50.withValues(alpha: 0.5),
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
        color: AppColors.background.withValues(alpha: 0.5),
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
        "Barchasini ko'rish >",
        style: TextStyle(color: AppColors.primary, fontSize: 12),
      ),
    );
  }
}
