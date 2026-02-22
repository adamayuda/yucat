// import 'package:event_bus/event_bus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';
import 'package:yucat/features/profile/bloc/profile_event.dart';
import 'package:yucat/features/profile/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final LogScreenViewUsecase _logScreenViewUsecase;
  // final CurrentUserUsecase currentUserUsecase;
  // final SignOutUsecase signOutUsecase;
  // final DeleteAccountUsecase deleteAccountUsecase;
  // final EventBus eventBus;

  ProfileBloc({required LogScreenViewUsecase logScreenViewUsecase})
    : _logScreenViewUsecase = logScreenViewUsecase,
      super(ProfileHiddenState()) {
    on<ProfileInitialEvent>(_onProfileInitialEvent);
  }

  Future<void> _onProfileInitialEvent(
    ProfileInitialEvent event,
    Emitter<ProfileState> emit,
  ) async {
    // _logScreenViewUsecase.call(screenName: 'ProfileScreen');
    emit(ProfileLoadingState());

    // final user = currentUserUsecase.call();

    emit(ProfileLoadedState());
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
