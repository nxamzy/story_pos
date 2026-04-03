import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/routes/platform_routes.dart';

class SupplierHeader extends StatelessWidget {
  const SupplierHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 15, bottom: 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Suppliers',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const Spacer(),
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(
                      Icons.person_add_alt_1_outlined,
                      color: AppColors.forestDark,
                    ),
                    SizedBox(width: 10),
                    Text("Import From Contacts"),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.edit_note, color: AppColors.forestDark),
                    SizedBox(width: 10),
                    Text("Add Manual"),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 2) {
                context.push(PlatformRoutes.addNewSupplierPage.route);
              }
            },
          ),
        ],
      ),
    );
  }
}
