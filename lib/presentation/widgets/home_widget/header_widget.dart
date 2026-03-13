import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Buni qo'shish shart
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/presentation/bloc/profile/profile_bloc.dart';
import 'package:ocam_pos/presentation/bloc/profile/profile_state.dart';
import 'package:ocam_pos/routes/platform_routes.dart';

import 'date_card_widget.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar Image
              InkWell(
                onTap: () {
                  context.push(PlatformRoutes.profilePage.route);
                },
                child: Container(
                  height: 46,
                  width: 46,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: const Icon(Icons.person_outline_outlined),
                ),
              ),

              const SizedBox(width: 18),

              // 🔥 DINAMIK QISM: Ismni Bloc-dan olamiz
              Expanded(
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    // Agar ma'lumot yuklangan bo'lsa ismni ko'rsatamiz, bo'lmasa "..."
                    String displayName = "Yuklanmoqda...";

                    if (state is ProfileLoaded) {
                      displayName =
                          "${state.user.firstName} ${state.user.lastName}";
                    } else if (state is ProfileError) {
                      displayName = "Foydalanuvchi";
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hello,',
                          style: TextStyle(
                            color: Color(0xFF15294B),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          displayName, // Statik ism olib tashlandi!
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow
                              .ellipsis, // Ism uzun bo'lsa sig'diradi
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Notification Icon
              IconButton(
                onPressed: () {
                  context.push(PlatformRoutes.notificationsPage.route);
                },
                icon: const Icon(Icons.notifications_none),
                color: Colors.white,
              ),
              const SizedBox(width: 20),
            ],
          ),
          const SizedBox(height: 20),
          const DataCard(),
        ],
      ),
    );
  }
}
