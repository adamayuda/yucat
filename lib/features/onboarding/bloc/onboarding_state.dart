part of 'onboarding_bloc.dart';

enum OnBoardingPhase {
  welcome,
  valueCarousel,
  attribution,
  attributionDetails,
  socialProof,
  whyYucat,
  domainPitch,
  addCatIntro,
  success,
}

sealed class OnBoardingState extends Equatable {
  const OnBoardingState();
}

class OnBoardingLoadingState extends OnBoardingState {
  @override
  List<Object?> get props => [];
}

class OnBoardingReadyState extends OnBoardingState {
  final OnBoardingPhase phase;
  final int currentPage;
  final String? selectedSource;

  const OnBoardingReadyState({
    this.phase = OnBoardingPhase.welcome,
    this.currentPage = 0,
    this.selectedSource,
  });

  @override
  List<Object?> get props => [phase, currentPage, selectedSource];

  OnBoardingReadyState copyWith({
    OnBoardingPhase? phase,
    int? currentPage,
    String? selectedSource,
  }) => OnBoardingReadyState(
    phase: phase ?? this.phase,
    currentPage: currentPage ?? this.currentPage,
    selectedSource: selectedSource ?? this.selectedSource,
  );
}
