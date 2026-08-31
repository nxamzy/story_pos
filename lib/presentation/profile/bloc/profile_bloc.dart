import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/core/network/failure.dart';
import 'package:ocam_pos/data/repositories/user_repository.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_event.dart';
import 'package:ocam_pos/presentation/profile/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _repository;
  StreamSubscription? _subscription;

  ProfileBloc({required UserRepository userRepository})
    : _repository = userRepository,
      super(const ProfileState()) {
    on<LoadUserProfile>(_onLoad);
    on<ProfileUpdated>(
      (event, emit) => emit(
        state.copyWith(
          status: BlocStatus.success,
          user: event.user,
          clearError: true,
        ),
      ),
    );
    on<ProfileFailed>(
      (event, emit) => emit(
        state.copyWith(status: BlocStatus.failure, error: event.message),
      ),
    );
    on<UpdateUserProfile>(_onUpdate);
  }

  void _onLoad(LoadUserProfile event, Emitter<ProfileState> emit) {
    emit(state.copyWith(status: BlocStatus.loading, clearError: true));
    _subscription?.cancel();
    _subscription = _repository.watchProfile().listen(
      (user) => add(ProfileUpdated(user)),
      onError: (Object error) => add(ProfileFailed(Failure.from(error).message)),
    );
  }

  Future<void> _onUpdate(
    UpdateUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state.user;
    if (current == null) return;

    try {
      await _repository.updateProfile(
        current.copyWith(
          firstName: event.firstName,
          lastName: event.lastName,
          phone: event.phone,
        ),
      );
      emit(state.copyWith(actionMessage: "Profil yangilandi", clearError: true));
    } catch (error) {
      emit(state.copyWith(error: Failure.from(error).message));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
