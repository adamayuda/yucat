part of 'onboarding_bloc.dart';

enum OnBoardingPhase {
  welcome,
  scanDemo,
  // Was `attribution` ("How did you hear about us?"). The screen is parked in
  // widgets/attribution_screen.dart — the slot, and so every `step_index`
  // after it, is unchanged; only `step_name` at index 2 differs.
  recipesArticles,
  proofChart,
  whyYucat,
  nutritionFact,
  profileIntro,
  profileName,
  rating,
  notifPrimer,
  reminders,
  healthIntro,
}

/// Stable, append-only analytics ids for [OnBoardingPhase].
///
/// The enum ordinal is the *position* in the PageView and changes whenever a
/// screen is inserted, removed or swapped — which already happened once:
/// `attribution` held ordinal 2 for 485 events before `recipesArticles` took
/// the slot, so every historical funnel keyed on `step_index = 2` now mixes
/// two unrelated screens.
///
/// [stepId] is the fix. A phase keeps its id forever; a replacement screen
/// takes the next free number rather than inheriting the slot. Never reuse or
/// renumber an entry here — retired ids (2 = `attribution`) stay retired.
extension OnBoardingPhaseAnalytics on OnBoardingPhase {
  static const _ids = <OnBoardingPhase, int>{
    OnBoardingPhase.welcome: 0,
    OnBoardingPhase.scanDemo: 1,
    // 2 is burned: it belonged to the parked `attribution` screen.
    OnBoardingPhase.proofChart: 3,
    OnBoardingPhase.whyYucat: 4,
    OnBoardingPhase.nutritionFact: 5,
    OnBoardingPhase.profileIntro: 6,
    OnBoardingPhase.profileName: 7,
    OnBoardingPhase.rating: 8,
    OnBoardingPhase.notifPrimer: 9,
    OnBoardingPhase.reminders: 10,
    OnBoardingPhase.healthIntro: 11,
    OnBoardingPhase.recipesArticles: 12,
  };

  int get stepId => _ids[this]!;
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

  /// Structured profile recap for the created cat, returned by the wizard and
  /// shown on the success screen. Null until the wizard completes.
  final CatSummary? catSummary;

  const OnBoardingReadyState({
    this.phase = OnBoardingPhase.welcome,
    this.selectedSource,
    this.seededName,
    this.seededPhotoPath,
    this.catSummary,
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
    CatSummary? catSummary,
  }) => OnBoardingReadyState(
    phase: phase ?? this.phase,
    selectedSource: selectedSource ?? this.selectedSource,
    seededName: seededName ?? this.seededName,
    seededPhotoPath: seededPhotoPath ?? this.seededPhotoPath,
    catSummary: catSummary ?? this.catSummary,
  );
}
