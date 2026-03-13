import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';

void showNewProfile(BuildContext context) {
  // Controllerlar xotirada qolishi uchun builder ichidan tashqariga olindi
  final nameController = TextEditingController(text: "Osama Al-Ghamri");
  final phoneController = TextEditingController(text: "01033980808");
  final addressController = TextEditingController(
    text: "25 Mohamed Awadullah St.",
  );
  final roleController = TextEditingController(text: "Accountant");

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle Bar
                    Container(
                      width: 45,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 25),
                      decoration: BoxDecoration(
                        color: AppColors.mintMedium,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "New Employee Profile",
                        style: TextStyle(
                          color: AppColors.forestDark,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Rasm yuklash qismi
                    Center(
                      child: InkWell(
                        onTap: () {}, // Galereyani ochish
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 110,
                          width: 110,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.mintLight,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_a_photo_rounded,
                                size: 32,
                                color: AppColors.primary,
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Add Image",
                                style: TextStyle(
                                  color: AppColors.sage,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Input Fields
                    _buildInputField("Full Name", nameController),
                    _buildInputField(
                      "Phone Number",
                      phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildInputField("Office Address", addressController),
                    _buildInputField("Job Role", roleController),

                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Save Profile",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildInputField(
  String label,
  TextEditingController controller, {
  TextInputType keyboardType = TextInputType.text,
}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.mintLight, width: 1.5),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.sage,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextField(
                controller: controller,
                keyboardType: keyboardType,
                style: const TextStyle(
                  color: AppColors.forestDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 6),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => controller.clear(),
          icon: const Icon(
            Icons.cancel_rounded,
            color: AppColors.mintMedium,
            size: 22,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    ),
  );
}
