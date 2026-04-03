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
        mainAxisSize: MainAxisSize.min, // Ustun faqat kerakli joyni egallaydi
        crossAxisAlignment: CrossAxisAlignment.start,
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

              // Ism qismi
              Expanded(
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    String displayName = "Yuklanmoqda...";
                    if (state is ProfileLoaded) {
                      displayName =
                          "${state.user.firstName} ${state.user.lastName}";
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hello,',
                          style: TextStyle(
                            color: Color(0xFF15294B),
                            fontSize:
                                14, // Biroq kichraytirdik, chiroyli chiqadi
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
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
            ],
          ),
          const SizedBox(height: 20),

          const DataCard(),
        ],
      ),
    );
  }
}
