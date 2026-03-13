import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/presentation/widgets/profile_widget/profile_selection_item.dart';
import 'package:ocam_pos/routes/platform_routes.dart';

void showConfirmSelect(BuildContext context) {
  int selectedIndex = 0;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
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
                  // Handle Bar
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
                      "Select Profile",
                      style: TextStyle(
                        color: AppColors.forestDark,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Profillar ro'yxati
                  ProfileSelectionItem(
                    index: 0,
                    name: "Marwan Magdy",
                    role: "Super Admin",
                    isSelected: selectedIndex == 0,
                    onTap: () => setModalState(() => selectedIndex = 0),
                  ),
                  ProfileSelectionItem(
                    index: 1,
                    name: "Mohamed Ahmed",
                    role: "Cashier",
                    isSelected: selectedIndex == 1,
                    onTap: () => setModalState(() => selectedIndex = 1),
                  ),

                  const SizedBox(height: 12),

                  // Show All Profiles tugmasi
                  _buildShowAllBtn(context),

                  const SizedBox(height: 24),

                  // Switch Button
                  _buildSwitchBtn(context, selectedIndex),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
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
            "Show All Profiles",
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

Widget _buildSwitchBtn(BuildContext context, int index) {
  return SizedBox(
    width: double.infinity,
    height: 58,
    child: ElevatedButton(
      onPressed: () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: const Text(
        "Switch Profile",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
