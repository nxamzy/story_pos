import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/data/models/supplier_model.dart'; // Modelni chaqiramiz
import 'package:ocam_pos/data/repositories/supplier_repository.dart'; // Repositoryni chaqiramiz
import 'package:ocam_pos/presentation/pages/supplier/addNewSupplier.dart';
import 'package:ocam_pos/presentation/widgets/supplier_widget/supplier_card.dart';
import 'package:ocam_pos/presentation/widgets/supplier_widget/supplier_header.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  final _repository =
      SupplierRepository(); // 🔥 Firebase bilan gaplashadigan 'Jangchi'
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ''; // Qidiruv so'zini saqlash uchun

  @override
  void initState() {
    super.initState();
    // Qidiruv maydoniga nimadir yozilsa, ekranni yangilaymiz
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const SupplierHeader(),

          // 🔍 Qidiruv va Filtr
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.mintLight),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search by supplier name',
                        hintStyle: TextStyle(
                          color: AppColors.sage,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.mintLight),
                  ),
                  child: const Icon(Icons.tune, color: AppColors.primary),
                ),
              ],
            ),
          ),

          // 📡 Jonli Ma'lumotlar oqimi (StreamBuilder)
          Expanded(
            child: StreamBuilder<List<SupplierModel>>(
              stream: _repository
                  .getSuppliers(), // Firebase'dan doimiy quloq solib turadi
              builder: (context, snapshot) {
                // 1. Kutish holati
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                // 2. Xatolik holati
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Xatolik: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                // 3. Ma'lumotlarni olish va filtrlash
                final suppliers = snapshot.data ?? [];
                final filteredSuppliers = suppliers.where((s) {
                  return s.name.toLowerCase().contains(_searchQuery);
                }).toList();

                // 4. Agar ro'yxat bo'sh bo'lsa
                if (filteredSuppliers.isEmpty) {
                  return _buildEmptyState();
                }

                // 5. Natijani ko'rsatish
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredSuppliers.length,
                  itemBuilder: (context, index) {
                    return SupplierCard(
                      supplier: filteredSuppliers[index],
                    ); // 🔥 Modelni berib yuboryapmiz
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 🎨 BO'SH HOLAT VIDJETI ---
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center_outlined,
              size: 80,
              color: AppColors.sage.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              "Taminotchilar topilmadi!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.forestDark,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              child: Text(
                "Hozircha hech qanday taminotchi qo'shilmagan yoki qidiruv natijasi bo'sh. Hamkorlarni qo'shing va tizimni kengaytiring!",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.sage),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 🔥 Bosganda qo'shish sahifasiga o'tadi
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddSupplierScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Taminotchi qo'shish",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
