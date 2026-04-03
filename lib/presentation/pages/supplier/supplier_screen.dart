import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/data/models/supplier_model.dart';
import 'package:ocam_pos/data/repositories/supplier_repository.dart';
import 'package:ocam_pos/presentation/pages/supplier/addNewSupplier.dart';
import 'package:ocam_pos/presentation/widgets/home_widget/date_card_widget.dart';
import 'package:ocam_pos/presentation/widgets/supplier_widget/supplier_card.dart';
import 'package:ocam_pos/presentation/widgets/supplier_widget/supplier_header.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  final _repository = SupplierRepository();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  DateTime? _selectedDate; // 🔥 Tanlangan sana holati

  @override
  void initState() {
    super.initState();
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

          // 🛠 FILTER & SEARCH SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Row(
              children: [
                // 📅 Aqlli Sana Kartasi
                DataCard(
                  initialDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate =
                          date; // Sana tanlanganda Stream yangilanadi
                    });
                  },
                ),
                const SizedBox(width: 12),

                // 🔍 Qidiruv maydoni
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.mintLight),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.forestDark.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search...',
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
              ],
            ),
          ),

          // 📡 STREAM BUILDER (JONLI MA'LUMOTLAR)
          Expanded(
            child: StreamBuilder<List<SupplierModel>>(
              // 🔥 Sanani repositoryga uzatyapmiz
              stream: _repository.getSuppliers(selectedDate: _selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Xatolik yuz berdi!",
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  );
                }

                final suppliers = snapshot.data ?? [];

                // Matnli qidiruv filtri
                final filtered = suppliers.where((s) {
                  return s.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return SupplierCard(supplier: filtered[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 🎨 EMPTY STATE ---
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Icon(
              Icons.person_search_outlined,
              size: 80,
              color: AppColors.sage.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              "Ta'minotchi topilmadi",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.forestDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedDate == null
                  ? "Hozircha hech qanday ma'lumot yo'q."
                  : "Ushbu sanada ma'lumotlar mavjud emas.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.sage),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddSupplierScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                "Yangi qo'shish",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
