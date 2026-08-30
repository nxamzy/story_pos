import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/presentation/onboarding/bloc/onboarding_event.dart';
import 'package:ocam_pos/presentation/onboarding/bloc/onboarding_state.dart';

/// Onboarding (tanishtiruv) sahifalari orasidagi holatni saqlaydi.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingState()) {
    on<OnboardingPageChanged>(
      (event, emit) => emit(state.copyWith(currentPage: event.page)),
    );
    on<OnboardingCompleted>(
      (event, emit) => emit(state.copyWith(isCompleted: true)),
    );
  }
}
