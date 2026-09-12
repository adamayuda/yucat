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
import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';
import 'package:yucat/features/saved_products/domain/usecases/get_saved_litters_usecase.dart';
import 'package:yucat/features/scan_history/domain/usecases/get_litter_history_usecase.dart';
import 'package:yucat/services/qa_reset_service.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  final SharedPreferences _prefs;
  final GetCatsUsecase _getCatsUsecase;
  final GetSavedProductsUsecase _getSavedProductsUsecase;
  final GetScanHistoryUsecase _getScanHistoryUsecase;
  final GetSavedLittersUsecase _getSavedLittersUsecase;
  final GetLitterHistoryUsecase _getLitterHistoryUsecase;
  final CurrentUserUsecase _currentUserUsecase;
  final QaResetService _qaResetService;

  ProfileBloc({
    required SharedPreferences prefs,
    required GetCatsUsecase getCatsUsecase,
    required GetSavedProductsUsecase getSavedProductsUsecase,
    required GetScanHistoryUsecase getScanHistoryUsecase,
    required GetSavedLittersUsecase getSavedLittersUsecase,
    required GetLitterHistoryUsecase getLitterHistoryUsecase,
    required CurrentUserUsecase currentUserUsecase,
    required QaResetService qaResetService,
  })  : _prefs = prefs,
        _getCatsUsecase = getCatsUsecase,
        _getSavedProductsUsecase = getSavedProductsUsecase,
        _getScanHistoryUsecase = getScanHistoryUsecase,
        _getSavedLittersUsecase = getSavedLittersUsecase,
        _getLitterHistoryUsecase = getLitterHistoryUsecase,
        _currentUserUsecase = currentUserUsecase,
        _qaResetService = qaResetService,
        super(ProfileHiddenState()) {
    on<ProfileInitialEvent>(_onProfileInitialEvent);
    on<ResetOnboardingTapEvent>(_onResetOnboardingTapEvent);
    on<ResetTestUserTapEvent>(_onResetTestUserTapEvent);
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

    // Litter lives in its own stores but shares the two library rows, so the
    // counts there are the sum of both categories.
    List<LitterDisplayModel> savedLitters = const [];
    try {
      savedLitters = await _getSavedLittersUsecase();
    } catch (_) {
      // Library preview falls back to empty on read failure.
    }

    List<LitterDisplayModel> litterHistory = const [];
    try {
      litterHistory = await _getLitterHistoryUsecase();
    } catch (_) {
      // Library preview falls back to empty on read failure.
    }

    emit(ProfileLoadedState(
      cats: cats,
      savedProducts: savedProducts,
      savedLitters: savedLitters,
      scanHistory: scanHistory,
      litterHistory: litterHistory,
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

  /// Back through splash rather than straight to onboarding: splash is where
  /// the new anonymous uid is minted and linked to Mixpanel, OneSignal and
  /// RevenueCat, and prefs are empty so it routes to onboarding by itself.
  /// Root blocs keep the old user's in-memory state until the next cold
  /// launch; good enough for a QA tool.
  Future<void> _onResetTestUserTapEvent(
    ResetTestUserTapEvent event,
    Emitter<ProfileState> emit,
  ) async {
    await _qaResetService.resetTestUser();
    if (event.context.mounted) {
      event.context.router.replaceAll([const SplashRoute()]);
    }
  }
}
