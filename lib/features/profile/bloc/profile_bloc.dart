// import 'package:event_bus/event_bus.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/features/profile/bloc/profile_event.dart';
import 'package:yucat/features/profile/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  final SharedPreferences _prefs;

  ProfileBloc({
    required SharedPreferences prefs,
  }) : _prefs = prefs,
       super(ProfileHiddenState()) {
    on<ProfileInitialEvent>(_onProfileInitialEvent);
    on<ResetOnboardingTapEvent>(_onResetOnboardingTapEvent);
  }

  Future<void> _onProfileInitialEvent(
    ProfileInitialEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoadingState());

    // final user = currentUserUsecase.call();

    emit(ProfileLoadedState());
  }

  Future<void> _onResetOnboardingTapEvent(
    ResetOnboardingTapEvent event,
    Emitter<ProfileState> emit,
  ) async {
    await _prefs.remove(_onboardingCompletedKey);
    if (event.context.mounted) {
      event.context.router.replaceAll([const OnBoardingRoute()]);
    }
  }

  // Future<void> _onLogoutTapEvent(
  //   LogoutTapEvent event,
  //   Emitter<ProfileState> emit,
  // ) async {
  //   await signOutUsecase.call();
  //   eventBus.fire(NewEsimEvent());

  //   emit(const ProfileLoadedState(isUserLoggedIn: false));
  // }

  // Future<void> _onLoginTapEvent(
  //   LoginTapEvent event,
  //   Emitter<ProfileState> emit,
  // ) async {
  //   await event.context.router.push(const AuthRoute());
  //   eventBus.fire(NewEsimEvent());

  //   emit(const ProfileLoadedState(isUserLoggedIn: true));
  // }

  // Future<void> _onDeleteAccountTapEvent(
  //   DeleteAccountTapEvent event,
  //   Emitter<ProfileState> emit,
  // ) async {
  //   await deleteAccountUsecase.call();
  //   eventBus.fire(NewEsimEvent());

  //   emit(const ProfileLoadedState(isUserLoggedIn: false));
  // }
}
