import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/data/models/customer_model.dart';
import 'package:ocam_pos/presentation/pages/customers/customer_details.dart';

// 🔥 1. Modalni chaqirishda endi MIJOZni ham berib yuboramiz
void showSuccessInventory(BuildContext context, CustomerModel customer) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => SuccessCustomerSheet(customer: customer),
  );
}

class SuccessCustomerSheet extends StatelessWidget {
  // 🔥 2. Konstruktorda mijozni qabul qilamiz
  final CustomerModel customer;
  const SuccessCustomerSheet({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(
        24,
        12,
        24,
        40,
      ), // Pastki paddingni oshirdik
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),

          // 3D Illustration
          Image.network(
            'https://ouch-cdn2.icons8.com/6U8m8mB9zWz_Y_XnS2vH7W_pUuQ6Z8-I1_2O6_0v8q8/rs:fit:256:256/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9wbmcvMzcy/L2M4ZGM0ZTMtM2Fj/Ny00YmU0LWJmMTYt/NjQ5YmQ4YjA1YjYy/LnBuZw.png',
            height: 160,
          ),
          const SizedBox(height: 20),

          const Text(
            "Added Successfully",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 30),

          // 3. MIJOZ KARTOCHKASI (Preview) - Parametr uzatildi
          _buildCustomerPreview(context, customer),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 45,
      height: 5,
      margin: const EdgeInsets.only(bottom: 25, top: 8),
      decoration: BoxDecoration(
        color: AppColors.mintLight,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildCustomerPreview(BuildContext context, CustomerModel customer) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.pop(context); // Oldin modalni yopamiz
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerDetailsPage(customer: customer),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.mintLight),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                customer.name[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.forestDark,
                    ),
                  ),
                  Text(
                    customer.phone,
                    style: const TextStyle(fontSize: 14, color: AppColors.sage),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
