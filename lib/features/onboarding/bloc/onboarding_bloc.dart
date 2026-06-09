import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';
import 'package:yucat/features/cat_create/presentation/models/cat_summary.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnBoardingBloc extends Bloc<OnBoardingEvent, OnBoardingState> {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  final SharedPreferences _prefs;
  final LogScreenViewUsecase _logScreenViewUsecase;
  final LogEventUsecase _logEventUsecase;

  DateTime? _onboardingStartTime;
  int _stepsViewed = 0;

  OnBoardingBloc({
    required SharedPreferences prefs,
    required LogScreenViewUsecase logScreenViewUsecase,
    required LogEventUsecase logEventUsecase,
  }) : _prefs = prefs,
       _logScreenViewUsecase = logScreenViewUsecase,
       _logEventUsecase = logEventUsecase,
       super(OnBoardingLoadingState()) {
    on<OnBoardingInitialEvent>(_onOnBoardingInitialEvent);
    on<OnBoardingGetStartedEvent>(_onOnBoardingGetStartedEvent);
    on<OnBoardingBackToWelcomeEvent>(_onOnBoardingBackToWelcomeEvent);
    on<OnBoardingAttributionSelectedEvent>(_onOnBoardingAttributionSelectedEvent);
    on<OnBoardingAttributionSkippedEvent>(_onOnBoardingAttributionSkippedEvent);
    on<OnBoardingAdvancePhaseEvent>(_onOnBoardingAdvancePhaseEvent);
    on<OnBoardingPreviousPhaseEvent>(_onOnBoardingPreviousPhaseEvent);
    on<OnBoardingPhotoSeededEvent>(_onOnBoardingPhotoSeededEvent);
    on<OnBoardingNameSeededEvent>(_onOnBoardingNameSeededEvent);
    on<OnBoardingCompletedEvent>(_onOnBoardingCompletedEvent);
    on<OnBoardingFinalizedEvent>(_onOnBoardingFinalizedEvent);
  }

  OnBoardingReadyState _readyState() =>
      state is OnBoardingReadyState ? state as OnBoardingReadyState : const OnBoardingReadyState();

  Future<void> _onOnBoardingInitialEvent(
    OnBoardingInitialEvent event,
    Emitter<OnBoardingState> emit,
  ) async {
    _onboardingStartTime = DateTime.now();
    _stepsViewed = 1;

    _logEventUsecase.call(
      eventName: 'Onboarding Started',
      properties: {
        'source': 'first_launch',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    _logScreenViewUsecase.call(
      screenName: 'OnBoardingRoute',
      index: 0,
      name: 'welcome',
    );
    emit(const OnBoardingReadyState());
  }

  void _onOnBoardingGetStartedEvent(
    OnBoardingGetStartedEvent event,
    Emitter<OnBoardingState> emit,
  ) {
    _logEventUsecase.call(
      eventName: 'Onboarding Get Started Tapped',
      properties: {'timestamp': DateTime.now().toIso8601String()},
    );

    _stepsViewed++;
    _logScreenViewUsecase.call(
      screenName: 'OnBoardingRoute',
      index: _phaseIndex(OnBoardingPhase.scanDemo),
      name: 'scan_demo',
    );

    emit(const OnBoardingReadyState(phase: OnBoardingPhase.scanDemo));
  }

  void _onOnBoardingBackToWelcomeEvent(
    OnBoardingBackToWelcomeEvent event,
    Emitter<OnBoardingState> emit,
  ) {
    emit(const OnBoardingReadyState(phase: OnBoardingPhase.welcome));
  }

  void _onOnBoardingAttributionSelectedEvent(
    OnBoardingAttributionSelectedEvent event,
    Emitter<OnBoardingState> emit,
  ) {
    _logEventUsecase.call(
      eventName: 'Onboarding Attribution Selected',
      properties: {
        'source': event.source,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    const next = OnBoardingPhase.proofChart;

    _stepsViewed++;
    _logScreenViewUsecase.call(
      screenName: 'OnBoardingRoute',
      index: _phaseIndex(next),
      name: next.name,
    );

    emit(_readyState().copyWith(
      phase: next,
      selectedSource: event.source,
    ));
  }

  void _onOnBoardingAttributionSkippedEvent(
    OnBoardingAttributionSkippedEvent event,
    Emitter<OnBoardingState> emit,
  ) {
    _logEventUsecase.call(
      eventName: 'Onboarding Attribution Skipped',
      properties: {'timestamp': DateTime.now().toIso8601String()},
    );
    _stepsViewed++;
    emit(_readyState().copyWith(phase: OnBoardingPhase.proofChart));
  }

  void _onOnBoardingAdvancePhaseEvent(
    OnBoardingAdvancePhaseEvent event,
    Emitter<OnBoardingState> emit,
  ) {
    final current = _readyState();
    final next = switch (current.phase) {
      OnBoardingPhase.scanDemo => OnBoardingPhase.attribution,
      OnBoardingPhase.proofChart => OnBoardingPhase.whyYucat,
      OnBoardingPhase.whyYucat => OnBoardingPhase.nutritionFact,
      OnBoardingPhase.nutritionFact => OnBoardingPhase.profileIntro,
      OnBoardingPhase.profileIntro => OnBoardingPhase.profileName,
      OnBoardingPhase.profileName => OnBoardingPhase.rating,
      OnBoardingPhase.rating => OnBoardingPhase.notifPrimer,
      OnBoardingPhase.notifPrimer => OnBoardingPhase.reminders,
      OnBoardingPhase.reminders => OnBoardingPhase.healthIntro,
      _ => current.phase,
    };
    if (next != current.phase) {
      _stepsViewed++;
      _logScreenViewUsecase.call(
        screenName: 'OnBoardingRoute',
        index: _phaseIndex(next),
        name: next.name,
      );
    }
    emit(current.copyWith(phase: next));
  }

  void _onOnBoardingPreviousPhaseEvent(
    OnBoardingPreviousPhaseEvent event,
    Emitter<OnBoardingState> emit,
  ) {
    final current = _readyState();
    final prev = switch (current.phase) {
      OnBoardingPhase.scanDemo => OnBoardingPhase.welcome,
      OnBoardingPhase.attribution => OnBoardingPhase.scanDemo,
      OnBoardingPhase.proofChart => OnBoardingPhase.attribution,
      OnBoardingPhase.whyYucat => OnBoardingPhase.proofChart,
      OnBoardingPhase.nutritionFact => OnBoardingPhase.whyYucat,
      OnBoardingPhase.profileIntro => OnBoardingPhase.nutritionFact,
      OnBoardingPhase.profileName => OnBoardingPhase.profileIntro,
      OnBoardingPhase.rating => OnBoardingPhase.profileName,
      OnBoardingPhase.notifPrimer => OnBoardingPhase.rating,
      OnBoardingPhase.reminders => OnBoardingPhase.notifPrimer,
      OnBoardingPhase.healthIntro => OnBoardingPhase.reminders,
      _ => current.phase,
    };
    emit(current.copyWith(phase: prev));
  }

  void _onOnBoardingPhotoSeededEvent(
    OnBoardingPhotoSeededEvent event,
    Emitter<OnBoardingState> emit,
  ) {
    emit(_readyState().copyWith(seededPhotoPath: event.photoPath));
  }

  void _onOnBoardingNameSeededEvent(
    OnBoardingNameSeededEvent event,
    Emitter<OnBoardingState> emit,
  ) {
    emit(_readyState().copyWith(seededName: event.name));
  }

  int _phaseIndex(OnBoardingPhase phase) {
    return OnBoardingPhase.values.indexOf(phase);
  }

  void _onOnBoardingCompletedEvent(
    OnBoardingCompletedEvent event,
    Emitter<OnBoardingState> emit,
  ) {
    // D0 "Add my cat" → push the wizard. On success the wizard invokes
    // [onCreated] (below), which pushes the success screen *over* the wizard so
    // it slides in forward (from the right) like any step. On cancel the wizard
    // just pops back to the health-intro screen, so there's nothing to do here.
    // The final analytics + paywall hand-off fire when the user taps "Start
    // scanning" on the success screen (see _onOnBoardingFinalizedEvent).
    final current = _readyState();

    event.context.router.push(
      CreateCatRoute(
        seededName: current.seededName,
        seededPhotoPath: current.seededPhotoPath,
        onCreated: (wizardContext, summary) {
          // A cat was actually created — mark onboarding complete and slide in
          // the success screen over the wizard.
          _prefs.setBool(_onboardingCompletedKey, true);
          wizardContext.router.push(
            SuccessRoute(
              summary: summary,
              onStart: (successContext) => add(
                OnBoardingFinalizedEvent(context: successContext),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onOnBoardingFinalizedEvent(
    OnBoardingFinalizedEvent event,
    Emitter<OnBoardingState> emit,
  ) async {
    final totalTimeSeconds = _onboardingStartTime != null
        ? DateTime.now().difference(_onboardingStartTime!).inSeconds
        : null;

    _logEventUsecase.call(
      eventName: 'Onboarding Completed',
      properties: {
        'total_time_seconds': totalTimeSeconds,
        'steps_viewed': _stepsViewed,
        'attribution_source': _readyState().selectedSource,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Hard gate: the paywall is the final beat of onboarding and cannot be
    // dismissed. push() only returns once the user has subscribed (or restored
    // an existing subscription), so we only ever reach the main app after that.
    final router = event.context.router;
    await router.push(PaywallRoute(dismissible: false));
    // replaceAll (not replace) because the stack now holds onboarding → wizard
    // → success underneath; clear them all so Main is the sole route.
    await router.replaceAll([const MainRoute()]);
  }
}
