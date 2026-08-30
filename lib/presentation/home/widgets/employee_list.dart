import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/presentation/employee/bloc/employee_bloc.dart';
import 'package:ocam_pos/presentation/employee/bloc/employee_event.dart';
import 'package:ocam_pos/presentation/employee/bloc/employee_state.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';

class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({super.key});

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
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
        title: const Text("Xodimlar"),
        backgroundColor: AppColors.forestDark,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<EmployeeBloc, EmployeeState>(
        builder: (context, state) {
          if (state.employees.isEmpty) {
            return const Center(
              child: Text(
                "Xodimlar yo'q",
                style: TextStyle(color: AppColors.sage),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.employees.length,
            itemBuilder: (context, index) {
              final emp = state.employees[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(emp.name.isNotEmpty ? emp.name[0] : "?"),
                  ),
                  title: Text(emp.name),
                  subtitle: Text(emp.role),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(
                    PlatformRoutes.employeeHRMPage.route,
                    extra: emp,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
