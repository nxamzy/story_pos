import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class OnboardingPageChanged extends OnboardingEvent {
  final int page;
  const OnboardingPageChanged(this.page);

  @override
  List<Object?> get props => [page];
}

class OnboardingCompleted extends OnboardingEvent {
  const OnboardingCompleted();
}
