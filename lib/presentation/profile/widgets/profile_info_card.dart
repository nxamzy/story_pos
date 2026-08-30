import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_bloc.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_state.dart';

class ProfileInfoCard extends StatelessWidget {
  final VoidCallback? onEditTap;

  const ProfileInfoCard({super.key, this.onEditTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final name = state.user?.fullName ?? "Foydalanuvchi";
        final email = state.user?.email ?? "";

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.mintLight, width: 2),
            ),
            child: const CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.mintLight,
              child: Icon(Icons.person, size: 30, color: AppColors.sage),
            ),
          ),
          title: Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.forestDark,
            ),
          ),
          subtitle: Text(
            email,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.sage,
              height: 1.2,
            ),
          ),
          trailing: IconButton(
            onPressed: onEditTap,
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.forestDark,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}
