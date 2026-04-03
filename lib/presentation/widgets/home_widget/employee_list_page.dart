import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/data/models/employee_model.dart';
import 'package:ocam_pos/routes/platform_routes.dart';

class EmployeeListPage extends StatelessWidget {
  const EmployeeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<EmployeeModel> employees = [
      EmployeeModel(
        id: "1",
        name: "Sening Isming (Admin)",
        role: "Owner",
        phone: "+998 90 123 45 67",
        imageUrl: "",
        salary: 0,
        createdAt: DateTime.now(),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Employees"),
        backgroundColor: AppColors.forestDark,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final emp = employees[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(emp.name[0])),
              title: Text(emp.name),
              subtitle: Text(emp.role),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.push(PlatformRoutes.employeeHRMPage.route, extra: emp);
              },
            ),
          );
        },
      ),
    );
  }
}
