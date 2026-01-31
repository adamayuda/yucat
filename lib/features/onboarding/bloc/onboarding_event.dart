part of 'onboarding_bloc.dart';

sealed class OnBoardingEvent extends Equatable {
  const OnBoardingEvent();
}

class OnBoardingInitialEvent extends OnBoardingEvent {
  final BuildContext context;

  const OnBoardingInitialEvent({required this.context});

  @override
  List<Object?> get props => [context];
}

class OnBoardingCompletedEvent extends OnBoardingEvent {
  final BuildContext context;

  const OnBoardingCompletedEvent({required this.context});

  @override
  List<Object?> get props => [context];
}

class OnBoardingSkipEvent extends OnBoardingEvent {
  final BuildContext context;

  const OnBoardingSkipEvent({required this.context});

  @override
  List<Object?> get props => [context];
}
