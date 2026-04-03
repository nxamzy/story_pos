import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/presentation/pages/profile/new_profile.dart';

class ShowAllProfile extends StatelessWidget {
  const ShowAllProfile({super.key});

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
          'All Profiles',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => showNewProfile(context),
            icon: const Icon(
              Icons.person_add_alt_1,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.mintLight, height: 1.0),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 12),
        physics: const BouncingScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) {
          return _buildProfileCard(
            name: "Marwan Magdy $index",
            email: "marwanmagdy200@gmail.com",
            onTap: () {},
          );
        },
      ),
    );
  }

  Widget _buildProfileCard({
    required String name,
    required String email,
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
              color: AppColors.forestDark.withOpacity(0.02),
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
            email,
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
