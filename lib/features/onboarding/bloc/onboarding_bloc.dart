import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnBoardingBloc extends Bloc<OnBoardingEvent, OnBoardingState> {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  final SharedPreferences _prefs;
  final LogScreenViewUsecase _logScreenViewUsecase;
  OnBoardingBloc({
    required SharedPreferences prefs,
    required LogScreenViewUsecase logScreenViewUsecase,
  }) : _prefs = prefs,
       _logScreenViewUsecase = logScreenViewUsecase,
       super(OnBoardingLoadingState()) {
    on<OnBoardingInitialEvent>(_onOnBoardingInitialEvent);
    on<OnBoardingCompletedEvent>(_onOnBoardingCompletedEvent);
  }

  Future<void> _onOnBoardingInitialEvent(
    OnBoardingInitialEvent event,
    Emitter<OnBoardingState> emit,
  ) async {
    _logScreenViewUsecase.call(screenName: 'OnBoardingScreen');
    print('OnBoardingBloc _onOnBoardingInitialEvent');
    emit(OnBoardingLoadingState());
    // emit(OnBoardingReadyState());

    // Check if onboarding has already been completed
    final isCompleted = _prefs.getBool(_onboardingCompletedKey) ?? false;

    if (isCompleted) {
      // If already completed, redirect to home
      event.context.router.replaceNamed('/main/home');
    } else {
      // If not completed, show onboarding
      emit(OnBoardingReadyState());
    }
  }

  Future<void> _onOnBoardingCompletedEvent(
    OnBoardingCompletedEvent event,
    Emitter<OnBoardingState> emit,
  ) async {
    print('OnBoardingBloc _onOnBoardingCompletedEvent');

    // Save onboarding completion status
    await _prefs.setBool(_onboardingCompletedKey, true);

    // Navigate to home (MainRoute with HomeRoute as active tab) when onboarding is completed
    event.context.router.replaceNamed('/main/home');
  }
}
