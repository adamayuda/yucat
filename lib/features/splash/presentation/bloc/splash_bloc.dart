import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/config/routes/router.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  final SharedPreferences _prefs;

  SplashBloc({required SharedPreferences prefs})
    : _prefs = prefs,
      super(SplashLoadingState()) {
    on<SplashInitialEvent>(_onSplashInitialEvent);
  }

  Future<void> _onSplashInitialEvent(
    SplashInitialEvent event,
    Emitter<SplashState> emit,
  ) async {
    emit(SplashLoadingState());
    // event.context.router.replace(const OnBoardingRoute());
    // return;
    final isCompleted = _prefs.getBool(_onboardingCompletedKey) ?? false;

    if (isCompleted) {
      event.context.router.replace(const HomeRoute());
    } else {
      event.context.router.replace(const OnBoardingRoute());
    }
  }
}
