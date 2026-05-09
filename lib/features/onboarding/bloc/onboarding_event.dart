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

class OnBoardingGetStartedEvent extends OnBoardingEvent {
  const OnBoardingGetStartedEvent();

  @override
  List<Object?> get props => [];
}

class OnBoardingBackToWelcomeEvent extends OnBoardingEvent {
  const OnBoardingBackToWelcomeEvent();

  @override
  List<Object?> get props => [];
}

class OnBoardingRestorePurchasesEvent extends OnBoardingEvent {
  const OnBoardingRestorePurchasesEvent();

  @override
  List<Object?> get props => [];
}

class OnBoardingValueCarouselCompletedEvent extends OnBoardingEvent {
  const OnBoardingValueCarouselCompletedEvent();

  @override
  List<Object?> get props => [];
}

class OnBoardingAttributionSelectedEvent extends OnBoardingEvent {
  final String source;

  const OnBoardingAttributionSelectedEvent(this.source);

  @override
  List<Object?> get props => [source];
}

class OnBoardingAttributionDetailsSubmittedEvent extends OnBoardingEvent {
  final String? text;

  const OnBoardingAttributionDetailsSubmittedEvent(this.text);

  @override
  List<Object?> get props => [text];
}

class OnBoardingAttributionSkippedEvent extends OnBoardingEvent {
  const OnBoardingAttributionSkippedEvent();

  @override
  List<Object?> get props => [];
}

class OnBoardingAdvancePhaseEvent extends OnBoardingEvent {
  const OnBoardingAdvancePhaseEvent();

  @override
  List<Object?> get props => [];
}

class OnBoardingPreviousPhaseEvent extends OnBoardingEvent {
  const OnBoardingPreviousPhaseEvent();

  @override
  List<Object?> get props => [];
}

class OnBoardingCompletedEvent extends OnBoardingEvent {
  final BuildContext context;

  const OnBoardingCompletedEvent({required this.context});

  @override
  List<Object?> get props => [context];
}

class OnBoardingFinalizedEvent extends OnBoardingEvent {
  final BuildContext context;

  const OnBoardingFinalizedEvent({required this.context});

  @override
  List<Object?> get props => [context];
}

class OnBoardingPageChangedEvent extends OnBoardingEvent {
  final int page;
  final String pageName;

  const OnBoardingPageChangedEvent(this.page, this.pageName);

  @override
  List<Object?> get props => [page, pageName];
}
