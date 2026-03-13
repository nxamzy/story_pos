import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🔥 Baza uchun
import 'package:firebase_auth/firebase_auth.dart'; // 🔥 Userni tanish uchun
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/data/models/product_model.dart'; // Modelingni tekshir
import 'package:ocam_pos/presentation/widgets/inventory_widget/inventory_product_card.dart';
import 'package:ocam_pos/routes/platform_routes.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // 1. Kategoriya bo'yicha filtr (Default: hammasi yoki birortasi)
  String selectedCategory = 'All';
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // FloatingActionButton qo'shib qo'ydim, tezkor qo'shish uchun
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => context.push(PlatformRoutes.addNewProduct.route),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchSection(),
          _buildCategorySection(),
          _buildListHeader(),
          // 2. StreamBuilder — Ma'lumotlarning "jon tomiri"
          Expanded(child: _buildDynamicProductList()),
        ],
      ),
    );
  }

  // --- 📦 BAZADAN MA'LUMOTLARNI OLISH ---
  Widget _buildDynamicProductList() {
    // Firestore so'rovini tayyorlaymiz
    Query query = FirebaseFirestore.instance
        .collection('products')
        .where('userId', isEqualTo: currentUserId);

    // Agar kategoriya 'All' bo'lmasa, uni ham filtrlaymiz
    if (selectedCategory != 'All') {
      query = query.where('category', isEqualTo: selectedCategory);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Xatolik yuz berdi: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        // 3. AGAR MAHSULOT YO'Q BO'LSA (Bo'sh holat)
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          physics: const BouncingScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final product = ProductModel.fromMap(data, docs[index].id);

            return InventoryProductCard(
              name: product.name,
              price: "${product.sellPrice} EGP",
              qty: "${product.stock} PC",
              imageUrl: product.imageUrl ?? 'https://via.placeholder.com/150',
              onTap: () {
                // 🎯 Kelajakda: Mahsulotni tahrirlash yoki tafsilotlarini ko'rish
                context.push(
                  PlatformRoutes.productDetails.route,
                  extra: product,
                );
              },
            );
          },
        );
      },
    );
  }

  // --- 🎨 BO'SH HOLAT VIDJETI ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: AppColors.sage.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            "Do'koningiz hozircha bo'sh!",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.forestDark,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            child: Text(
              "Mahsulotlarni qo'shing va savdoni boshlang. Har bir soniya — bu imkoniyat!",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.sage),
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push(PlatformRoutes.addNewProduct.route),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text(
              "Mahsulot qo'shish",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // --- 🏷 KATEGORIYALAR (DYNAMIC) ---
  Widget _buildCategorySection() {
    // 'All'ni qo'shib qo'ydimki, hamma narsani ko'rish imkoni bo'lsin
    List<String> cats = ['All', 'Beverages', 'Candy', 'Packaged Food', 'Home'];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestDark,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Kategoriya qo'shish mantiqi (Dialog ochish mumkin)
                },
                icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
                label: const Text(
                  'Add',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 46,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: cats.length,
            itemBuilder: (context, index) {
              bool isSelected = selectedCategory == cats[index];
              return _buildCategoryChip(cats[index], isSelected);
            },
          ),
        ),
      ],
    );
  }

  // Qolgan metodlar (_buildHeader, _buildSearchSection, _buildCategoryChip, _buildListHeader, _buildIconButton)
  // o'z joyida qoladi, faqat category chip bosilganda setState() bilan StreamBuilder yangilanadi.

  Widget _buildCategoryChip(String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory =
              title; // 🔥 Bu bosilganda StreamBuilder qayta filtrlanadi
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.mintLight,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.sage,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // --- 🛠 HEADER VA SEARCH (O'zingnikiga o'xshash, lekin toza holatda) ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 15, bottom: 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Inventory',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
          _buildHeaderActions(),
        ],
      ),
    );
  }

  Widget _buildHeaderActions() {
    return PopupMenuButton<int>(
      icon: const Icon(
        Icons.add_circle_outline_rounded,
        color: AppColors.white,
        size: 28,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 1, child: Text("Import CSV (Kelajakda)")),
        const PopupMenuItem(value: 2, child: Text("Add Manual")),
      ],
      onSelected: (v) {
        if (v == 2) context.push(PlatformRoutes.addNewProduct.route);
      },
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.mintLight),
              ),
              child: TextField(
                onChanged: (value) {
                  // 🎯 Qidiruv mantiqi (Kelajakda filter qo'shish mumkin)
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: AppColors.sage),
                  hintText: 'Search Product Here',
                  hintStyle: TextStyle(color: AppColors.sage),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildIconButton(Icons.qr_code_scanner_rounded),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'All Products',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.forestDark,
            ),
          ),
          Text(
            'See All',
            style: TextStyle(color: AppColors.sage, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      height: 54,
      width: 54,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mintLight),
      ),
      child: Icon(icon, color: AppColors.forestDark),
    );
  }
}
