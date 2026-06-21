import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/domain/usecases/get_cats_usecase.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/profile/bloc/profile_event.dart';
import 'package:yucat/features/profile/bloc/profile_state.dart';
import 'package:yucat/features/saved_products/domain/usecases/get_saved_products_usecase.dart';
import 'package:yucat/features/scan_history/domain/usecases/get_scan_history_usecase.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  final SharedPreferences _prefs;
  final GetCatsUsecase _getCatsUsecase;
  final GetSavedProductsUsecase _getSavedProductsUsecase;
  final GetScanHistoryUsecase _getScanHistoryUsecase;
  final CurrentUserUsecase _currentUserUsecase;

  ProfileBloc({
    required SharedPreferences prefs,
    required GetCatsUsecase getCatsUsecase,
    required GetSavedProductsUsecase getSavedProductsUsecase,
    required GetScanHistoryUsecase getScanHistoryUsecase,
    required CurrentUserUsecase currentUserUsecase,
  })  : _prefs = prefs,
        _getCatsUsecase = getCatsUsecase,
        _getSavedProductsUsecase = getSavedProductsUsecase,
        _getScanHistoryUsecase = getScanHistoryUsecase,
        _currentUserUsecase = currentUserUsecase,
        super(ProfileHiddenState()) {
    on<ProfileInitialEvent>(_onProfileInitialEvent);
    on<ResetOnboardingTapEvent>(_onResetOnboardingTapEvent);
  }

  Future<void> _onProfileInitialEvent(
    ProfileInitialEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoadingState());

    List<CatEntity> cats = const [];
    final user = _currentUserUsecase();
    if (user != null) {
      try {
        cats = await _getCatsUsecase(userId: user.uid);
      } catch (_) {
        // The cats section falls back to empty on read failure.
      }
    }

    List<ProductDisplayModel> savedProducts = const [];
    try {
      savedProducts = await _getSavedProductsUsecase();
    } catch (_) {
      // Library preview falls back to empty on read failure.
    }

    List<ProductDisplayModel> scanHistory = const [];
    try {
      scanHistory = await _getScanHistoryUsecase();
    } catch (_) {
      // Library preview falls back to empty on read failure.
    }

    emit(ProfileLoadedState(
      cats: cats,
      savedProducts: savedProducts,
      scanHistory: scanHistory,
    ));
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
}
