import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/widgets/app_snackbar.dart';
import 'package:ocam_pos/presentation/employee/bloc/employee_bloc.dart';
import 'package:ocam_pos/presentation/employee/bloc/employee_event.dart';
import 'package:ocam_pos/presentation/employee/bloc/employee_state.dart';
import 'package:ocam_pos/presentation/profile/widgets/profile_selection_item.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';

/// Kassir profillari orasida almashtirish.
///
/// Eslatma: hozircha faqat ko'rish uchun — haqiqiy "almashtirish" PIN yoki
/// boshqa xavfsizlik tekshiruvi talab qiladi, u hali loyihalanmagan.
/// Shu sababli tugma haqiqatda hech narsani o'zgartirmasdan yopilib
/// qolmasin deb, "Tez orada" xabarini ko'rsatadi.
void showConfirmSelect(BuildContext context) {
  final employeeBloc = context.read<EmployeeBloc>()..add(const LoadEmployees());
  String? selectedId;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return BlocProvider.value(
        value: employeeBloc,
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.mintMedium,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Profilni tanlash",
                        style: TextStyle(
                          color: AppColors.forestDark,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    BlocBuilder<EmployeeBloc, EmployeeState>(
                      builder: (context, state) {
                        if (state.status.isFirstLoad &&
                            state.employees.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          );
                        }
                        if (state.employees.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              "Hozircha xodimlar yo'q",
                              style: TextStyle(color: AppColors.sage),
                            ),
                          );
                        }
                        return Column(
                          children: state.employees
                              .map(
                                (employee) => ProfileSelectionItem(
                                  index: 0,
                                  name: employee.name,
                                  role: employee.role,
                                  isSelected: selectedId == employee.id,
                                  onTap: () => setModalState(
                                    () => selectedId = employee.id,
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildShowAllBtn(context),

                    const SizedBox(height: 24),

                    _buildSwitchBtn(context),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

Widget _buildShowAllBtn(BuildContext context) {
  return InkWell(
    onTap: () => context.push(PlatformRoutes.showAllProfile.route),
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.group_outlined, color: AppColors.primary),
          SizedBox(width: 12),
          Text(
            "Barcha profillarni ko'rish",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Spacer(),
          Icon(Icons.chevron_right, color: AppColors.primary),
        ],
      ),
    ),
  );
}

Widget _buildSwitchBtn(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    height: 58,
    child: ElevatedButton(
      onPressed: () => AppSnackBar.info(context, "Tez orada qo'shiladi"),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: const Text(
        "Profilni almashtirish",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
