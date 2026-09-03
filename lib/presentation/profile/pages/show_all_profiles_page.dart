import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';
import 'package:ocam_pos/presentation/employee/bloc/employee_bloc.dart';
import 'package:ocam_pos/presentation/employee/bloc/employee_event.dart';
import 'package:ocam_pos/presentation/employee/bloc/employee_state.dart';

class ShowAllProfile extends StatefulWidget {
  const ShowAllProfile({super.key});

  @override
  State<ShowAllProfile> createState() => _ShowAllProfileState();
}

class _ShowAllProfileState extends State<ShowAllProfile> {
  @override
  void initState() {
    super.initState();
    context.read<EmployeeBloc>().add(const LoadEmployees());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
        ),
        title: const Text(
          'Xodimlar',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                context.push(PlatformRoutes.addEmployee.route),
            icon: const Icon(
              Icons.person_add_alt_1,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: ColoredBox(color: AppColors.mintLight, child: SizedBox(height: 1.0)),
        ),
      ),
      body: BlocBuilder<EmployeeBloc, EmployeeState>(
        builder: (context, state) {
          if (state.employees.isEmpty) {
            return const Center(
              child: Text(
                "Hozircha xodimlar yo'q",
                style: TextStyle(color: AppColors.sage),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 12),
            physics: const BouncingScrollPhysics(),
            itemCount: state.employees.length,
            itemBuilder: (context, index) {
              final employee = state.employees[index];
              return _buildProfileCard(
                name: employee.name,
                subtitle: employee.role,
                onTap: () => context.push(
                  PlatformRoutes.employeeHRMPage.route,
                  extra: employee,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileCard({
    required String name,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.mintLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.forestDark.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.background,
            child: Icon(Icons.person, size: 30, color: AppColors.sage),
          ),
          title: Text(
            name,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.forestDark,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: AppColors.sage),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.mintMedium,
            size: 18,
          ),
        ),
      ),
    );
  }
}
