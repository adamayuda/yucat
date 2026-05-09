import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

const _influencerSource = 'influencer';

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
    on<OnBoardingRestorePurchasesEvent>(_onOnBoardingRestorePurchasesEvent);
    on<OnBoardingPageChangedEvent>(_onOnBoardingPageChangedEvent);
    on<OnBoardingValueCarouselCompletedEvent>(_onOnBoardingValueCarouselCompletedEvent);
    on<OnBoardingAttributionSelectedEvent>(_onOnBoardingAttributionSelectedEvent);
    on<OnBoardingAttributionDetailsSubmittedEvent>(_onOnBoardingAttributionDetailsSubmittedEvent);
    on<OnBoardingAttributionSkippedEvent>(_onOnBoardingAttributionSkippedEvent);
    on<OnBoardingAdvancePhaseEvent>(_onOnBoardingAdvancePhaseEvent);
    on<OnBoardingPreviousPhaseEvent>(_onOnBoardingPreviousPhaseEvent);
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

    _logScreenViewUsecase.call(
      screenName: 'OnBoardingRoute',
      index: 1,
      name: 'value_carousel_1',
    );

    emit(const OnBoardingReadyState(
      phase: OnBoardingPhase.valueCarousel,
      currentPage: 0,
    ));
  }

  void _onOnBoardingBackToWelcomeEvent(
    OnBoardingBackToWelcomeEvent event,
    Emitter<OnBoardingState> emit,
  ) {
    emit(const OnBoardingReadyState(phase: OnBoardingPhase.welcome));
  }

  void _onOnBoardingRestorePurchasesEvent(
    OnBoardingRestorePurchasesEvent event,
    Emitter<OnBoardingState> emit,
  ) {
    _logEventUsecase.call(
      eventName: 'Onboarding Restore Purchases Tapped',
      properties: {'timestamp': DateTime.now().toIso8601String()},
    );
    // Real RevenueCat restore flow lands later; no-op for now.
  }

  void _onOnBoardingPageChangedEvent(
    OnBoardingPageChangedEvent event,
    Emitter<OnBoardingState> emit,
  ) {
    _stepsViewed = event.page + 2;

    _logScreenViewUsecase.call(
      screenName: 'OnBoardingRoute',
      index: event.page + 1,
      name: event.pageName,
    );

    final current = _readyState();
    emit(current.copyWith(currentPage: event.page));
  }

  void _onOnBoardingValueCarouselCompletedEvent(
    OnBoardingValueCarouselCompletedEvent event,
    Emitter<OnBoardingState> emit,
  ) {
    _logScreenViewUsecase.call(
      screenName: 'OnBoardingRoute',
      index: 4,
      name: 'attribution',
    );
    emit(_readyState().copyWith(phase: OnBoardingPhase.attribution));
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

    final next = event.source == _influencerSource
        ? OnBoardingPhase.attributionDetails
        : OnBoardingPhase.socialProof;

    _logScreenViewUsecase.call(
      screenName: 'OnBoardingRoute',
      index: next == OnBoardingPhase.attributionDetails ? 5 : 6,
      name: next == OnBoardingPhase.attributionDetails
          ? 'attribution_details'
          : 'social_proof',
    );

    emit(_readyState().copyWith(
      phase: next,
      selectedSource: event.source,
    ));
  }

  void _onOnBoardingAttributionDetailsSubmittedEvent(
    OnBoardingAttributionDetailsSubmittedEvent event,
    Emitter<OnBoardingState> emit,
  ) {
    _logEventUsecase.call(
      eventName: 'Onboarding Attribution Details Submitted',
      properties: {
        'has_text': event.text != null && event.text!.isNotEmpty,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    emit(_readyState().copyWith(phase: OnBoardingPhase.socialProof));
  }

  void _onOnBoardingAttributionSkippedEvent(
    OnBoardingAttributionSkippedEvent event,
    Emitter<OnBoardingState> emit,
  ) {
    _logEventUsecase.call(
      eventName: 'Onboarding Attribution Skipped',
      properties: {'timestamp': DateTime.now().toIso8601String()},
    );
    emit(_readyState().copyWith(phase: OnBoardingPhase.socialProof));
  }

  void _onOnBoardingAdvancePhaseEvent(
    OnBoardingAdvancePhaseEvent event,
    Emitter<OnBoardingState> emit,
  ) {
    final current = _readyState();
    final next = switch (current.phase) {
      OnBoardingPhase.socialProof => OnBoardingPhase.whyYucat,
      OnBoardingPhase.whyYucat => OnBoardingPhase.domainPitch,
      OnBoardingPhase.domainPitch => OnBoardingPhase.addCatIntro,
      _ => current.phase,
    };
    if (next != current.phase) {
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
      OnBoardingPhase.attribution => OnBoardingPhase.valueCarousel,
      OnBoardingPhase.attributionDetails => OnBoardingPhase.attribution,
      OnBoardingPhase.socialProof =>
        current.selectedSource == _influencerSource
            ? OnBoardingPhase.attributionDetails
            : OnBoardingPhase.attribution,
      OnBoardingPhase.whyYucat => OnBoardingPhase.socialProof,
      OnBoardingPhase.domainPitch => OnBoardingPhase.whyYucat,
      OnBoardingPhase.addCatIntro => OnBoardingPhase.domainPitch,
      _ => current.phase,
    };
    emit(current.copyWith(phase: prev));
  }

  int _phaseIndex(OnBoardingPhase phase) {
    return OnBoardingPhase.values.indexOf(phase);
  }

  Future<void> _onOnBoardingCompletedEvent(
    OnBoardingCompletedEvent event,
    Emitter<OnBoardingState> emit,
  ) async {
    // D0 "Add my cat" → push wizard, persist completion flag, then on
    // wizard pop emit success phase so E0 renders. Final analytics fires
    // when the user taps "Start scanning" on E0 (see _onOnBoardingFinalizedEvent).
    await _prefs.setBool(_onboardingCompletedKey, true);

    await event.context.router.push(CreateCatRoute());

    emit(_readyState().copyWith(phase: OnBoardingPhase.success));

    _logScreenViewUsecase.call(
      screenName: 'OnBoardingRoute',
      index: _phaseIndex(OnBoardingPhase.success),
      name: 'success',
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

    event.context.router.replace(const MainRoute());
  }
}
