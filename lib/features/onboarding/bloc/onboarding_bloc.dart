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
    on<OnBoardingPageChangedEvent>(_onOnBoardingPageChangedEvent);
    on<OnBoardingCompletedEvent>(_onOnBoardingCompletedEvent);
    on<OnBoardingSkipEvent>(_onOnBoardingSkipEvent);
  }

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

  void _onOnBoardingPageChangedEvent(
    OnBoardingPageChangedEvent event,
    Emitter<OnBoardingState> emit,
  ) {
    _stepsViewed = event.page + 1;

    _logScreenViewUsecase.call(
      screenName: 'OnBoardingRoute',
      index: event.page,
      name: event.pageName,
    );

    emit(OnBoardingReadyState(currentPage: event.page));
  }

  Future<void> _onOnBoardingCompletedEvent(
    OnBoardingCompletedEvent event,
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
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    await _prefs.setBool(_onboardingCompletedKey, true);

    await event.context.router.push(CreateCatRoute());

    event.context.router.replace(const CatListingRoute());
  }

  Future<void> _onOnBoardingSkipEvent(
    OnBoardingSkipEvent event,
    Emitter<OnBoardingState> emit,
  ) async {
    final currentState = state;
    final currentPage = currentState is OnBoardingReadyState ? currentState.currentPage : 0;

    _logEventUsecase.call(
      eventName: 'Onboarding Skipped',
      properties: {
        'step_index': currentPage,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    await _prefs.setBool(_onboardingCompletedKey, true);

    await event.context.router.push(const PaywallRoute());

    event.context.router.replace(const HomeRoute());
  }
}
