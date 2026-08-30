import 'package:equatable/equatable.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/data/models/user_model.dart';

class ProfileState extends Equatable {
  final BlocStatus status;
  final UserModel? user;
  final String? error;
  final String? actionMessage;

  const ProfileState({
    this.status = BlocStatus.initial,
    this.user,
    this.error,
    this.actionMessage,
  });

  ProfileState copyWith({
    BlocStatus? status,
    UserModel? user,
    String? error,
    String? actionMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, error, actionMessage];
}
