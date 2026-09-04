import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_bloc.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_event.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_state.dart';
import 'package:ocam_pos/presentation/settings/widgets/settings_sheet_frame.dart';

/// Vaqt 24 soatlik yoki 12 soatlik ko'rsatilishi.
///
/// Tanlov `AppFormat.time` va `AppFormat.dateTime` orqali butun ilovaga —
/// savdolar tarixi, cheklar, kassa o'tkazmalari — tarqaladi.
void showTimeFormatSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => BlocProvider.value(
      value: context.read<ProfileBloc>(),
      child: const _TimeFormatSheet(),
    ),
  );
}

class _TimeFormatSheet extends StatelessWidget {
  const _TimeFormatSheet();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final use24 = state.user?.use24HourFormat ?? true;

        void select(bool value) {
          if (value != use24) {
            context.read<ProfileBloc>().add(
              UpdateStoreInfo(use24HourFormat: value),
            );
          }
          Navigator.pop(context);
        }

        return SettingsSheetFrame(
          title: "Vaqt formati",
          subtitle: "Sana va vaqt qanday ko'rsatilsin",
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SettingsChoiceTile(
                title: "24 soatlik",
                subtitle: "14:30",
                selected: use24,
                onTap: () => select(true),
              ),
              SettingsChoiceTile(
                title: "12 soatlik",
                subtitle: "2:30 PM",
                selected: !use24,
                onTap: () => select(false),
              ),
            ],
          ),
        );
      },
    );
  }
}
