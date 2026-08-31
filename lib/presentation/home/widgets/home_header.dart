import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_bloc.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_state.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/routes/app_routes.dart';

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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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

              Expanded(
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    final displayName = state.user?.fullName ??
                        (state.status.isFailure
                            ? "Profil topilmadi"
                            : "Yuklanmoqda...");

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Xush kelibsiz,',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
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

              IconButton(
                onPressed: () {
                  context.push(PlatformRoutes.notificationsPage.route);
                },
                icon: const Icon(Icons.notifications_none),
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
