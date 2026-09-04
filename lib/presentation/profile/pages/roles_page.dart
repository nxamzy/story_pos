import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/data/models/employee_model.dart';
import 'package:ocam_pos/presentation/employee/bloc/employee_bloc.dart';
import 'package:ocam_pos/presentation/employee/bloc/employee_state.dart';

/// Do'kondagi rollar va ularning imkoniyatlari.
///
/// Ilgari bu sahifa "Tez orada" xabarini chiqarardi. Aslida ilovada rol
/// tizimi bor — do'kon egasi va kassirlar — lekin uning chegaralari hech
/// qayerda tushuntirilmagan edi, ayniqsa PIN kodning ma'nosi.
class RolesPage extends StatelessWidget {
  const RolesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
        ),
        title: const Text(
          'Rol va ruxsatlar',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<EmployeeBloc, EmployeeState>(
        builder: (context, state) {
          final cashier = state.activeCashier;

          return ListView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            children: [
              _RoleCard(
                icon: Icons.store_mall_directory_outlined,
                title: "Do'kon egasi",
                isActive: cashier == null,
                permissions: const [
                  "Barcha bo'limlar: ombor, savdo, hisobot, kassa",
                  "Xodim qo'shish, tahrirlash va PIN belgilash",
                  "Do'kon sozlamalari, valyuta, chek ko'rinishi",
                  "Savdoni qaytarish va xarajat o'chirish",
                  "Hisobni butunlay o'chirish",
                ],
              ),
              const SizedBox(height: 12),
              _RoleCard(
                icon: Icons.point_of_sale_outlined,
                title: "Kassir",
                isActive: cashier != null,
                permissions: const [
                  "Savdo qilish — chek uning nomiga yoziladi",
                  "Ombordan mahsulot qidirish va skanerlash",
                  "Kassa balansini ko'rish",
                  "O'z hisob-kitobi (oylik, balans) tarixini ko'rish",
                ],
              ),

              const SizedBox(height: 20),
              _buildPinNote(),

              const SizedBox(height: 24),
              const Text(
                "Xodimlar",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestDark,
                ),
              ),
              const SizedBox(height: 12),

              if (state.employees.isEmpty)
                const _EmptyEmployees()
              else
                ..._buildGroupedEmployees(context, state.employees),
            ],
          );
        },
      ),
    );
  }

  /// Xodimlar lavozimi bo'yicha guruhlanadi — kimda qanday rol borligi
  /// bitta ro'yxatdan ko'rinadi.
  List<Widget> _buildGroupedEmployees(
    BuildContext context,
    List<EmployeeModel> employees,
  ) {
    final groups = <String, List<EmployeeModel>>{};
    for (final employee in employees) {
      final role = employee.role.trim().isEmpty
          ? "Lavozimi ko'rsatilmagan"
          : employee.role.trim();
      groups.putIfAbsent(role, () => []).add(employee);
    }

    final roles = groups.keys.toList()..sort();

    return [
      for (final role in roles) ...[
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6, left: 4),
          child: Text(
            "$role (${groups[role]!.length})",
            style: const TextStyle(
              color: AppColors.sage,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        for (final employee in groups[role]!)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.mintLight),
            ),
            child: ListTile(
              onTap: () => context.push(
                PlatformRoutes.employeeHRMPage.route,
                extra: employee,
              ),
              leading: CircleAvatar(
                backgroundColor: AppColors.mintLight,
                child: Text(
                  employee.name.isEmpty ? '?' : employee.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                employee.name,
                style: const TextStyle(
                  color: AppColors.forestDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                employee.pinHash.isEmpty
                    ? "PIN o'rnatilmagan"
                    : "PIN o'rnatilgan",
                style: TextStyle(
                  color: employee.pinHash.isEmpty
                      ? AppColors.error
                      : AppColors.sage,
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.sage,
                size: 20,
              ),
            ),
          ),
      ],
    ];
  }

  /// PIN nima ekanini ochiq aytish — u himoya emas, hisobot uchun imzo.
  Widget _buildPinNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mintLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mintLight),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Kassir PIN kodi — bu himoya emas, imzo. U savdo kim "
              "tomonidan qilinganini chekka va hisobotga yozish uchun "
              "so'raladi. Qurilmadagi barcha ma'lumot baribir do'kon "
              "egasining hisobiga tegishli, shuning uchun begona odamga "
              "ochiq qurilmani qoldirmang.",
              style: TextStyle(
                color: AppColors.forestDark,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> permissions;

  /// Hozir shu rolda ishlanayotgani.
  final bool isActive;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.permissions,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.mintLight,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.forestDark,
                  ),
                ),
              ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Hozir shu",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          for (final permission in permissions)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      permission,
                      style: const TextStyle(
                        color: AppColors.sage,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyEmployees extends StatelessWidget {
  const _EmptyEmployees();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mintLight),
      ),
      child: Column(
        children: [
          const Text(
            "Hali xodim qo'shilmagan — do'konda faqat siz ishlaysiz.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.sage),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => context.push(PlatformRoutes.addEmployee.route),
            icon: const Icon(Icons.person_add_alt_1_outlined),
            label: const Text("Xodim qo'shish"),
          ),
        ],
      ),
    );
  }
}
