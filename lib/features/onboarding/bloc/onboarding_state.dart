part of 'onboarding_bloc.dart';

enum OnBoardingPhase {
  welcome,
  scanDemo,
  attribution,
  attributionDetails,
  proofChart,
  whyYucat,
  nutritionFact,
  profileIntro,
  profileName,
  rating,
  notifPrimer,
  reminders,
  healthIntro,
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
  final String? selectedSource;

  /// Onboarding-seeded values handed to the wizard so it can skip the
  /// matching steps when launched from the onboarding flow.
  final String? seededName;
  final String? seededPhotoPath;

  /// At-a-glance chips for the created cat, returned by the wizard and
  /// shown on the success screen. Empty until the wizard completes.
  final List<String> catSummary;

  const OnBoardingReadyState({
    this.phase = OnBoardingPhase.welcome,
    this.selectedSource,
    this.seededName,
    this.seededPhotoPath,
    this.catSummary = const [],
  });

  @override
  List<Object?> get props => [
        phase,
        selectedSource,
        seededName,
        seededPhotoPath,
        catSummary,
      ];

  OnBoardingReadyState copyWith({
    OnBoardingPhase? phase,
    String? selectedSource,
    String? seededName,
    String? seededPhotoPath,
    List<String>? catSummary,
  }) => OnBoardingReadyState(
    phase: phase ?? this.phase,
    selectedSource: selectedSource ?? this.selectedSource,
    seededName: seededName ?? this.seededName,
    seededPhotoPath: seededPhotoPath ?? this.seededPhotoPath,
    catSummary: catSummary ?? this.catSummary,
  );
}
