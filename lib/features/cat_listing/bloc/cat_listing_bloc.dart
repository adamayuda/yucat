import 'package:auto_route/auto_route.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/get_cats_usecase.dart';
import 'package:yucat/features/cat_listing/mappers/cat_entity_to_model_mapper.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';
import 'package:yucat/features/paywall/paywall_page.dart';
import 'package:yucat/services/cat_tracking_service.dart';

part 'cat_listing_event.dart';
part 'cat_listing_state.dart';

class CatListingBloc extends Bloc<CatListingEvent, CatListingState> {
  final GetCatsUsecase _getCatsUsecase;
  final CatEntityToModelMapper _catEntityToModelMapper;
  final CurrentUserUsecase _currentUserUsecase;
  final LogScreenViewUsecase _logScreenViewUsecase;
  final CatTrackingService _catTrackingService;

  CatListingBloc({
    required GetCatsUsecase getCatsUsecase,
    required CatEntityToModelMapper catEntityToModelMapper,
    required CurrentUserUsecase currentUserUsecase,
    required LogScreenViewUsecase logScreenViewUsecase,
    required CatTrackingService catTrackingService,
  }) : _getCatsUsecase = getCatsUsecase,
       _catEntityToModelMapper = catEntityToModelMapper,
       _currentUserUsecase = currentUserUsecase,
       _logScreenViewUsecase = logScreenViewUsecase,
       _catTrackingService = catTrackingService,
       super(const CatListingLoadingState()) {
    on<CatListingInitialEvent>(_onCatListingInitialEvent);
    on<CatListingFetchCatsEvent>(_onCatListingFetchCatsEvent);
    on<CatListingCreateCatEvent>(_onCatListingCreateCatEvent);
  }

  Future<void> _onCatListingInitialEvent(
    CatListingInitialEvent event,
    Emitter<CatListingState> emit,
  ) async {
    // _logScreenViewUsecase.call(screenName: 'CatListingScreen');
    add(const CatListingFetchCatsEvent());
  }

  Future<void> _onCatListingFetchCatsEvent(
    CatListingFetchCatsEvent event,
    Emitter<CatListingState> emit,
  ) async {
    emit(const CatListingLoadingState());
    try {
      final user = _currentUserUsecase();
      if (user == null) {
        emit(const CatListingErrorState(message: 'User not authenticated'));
        return;
      }
      final cats = await _getCatsUsecase(userId: user.uid);
      final catModels = cats
          .map((cat) => _catEntityToModelMapper(cat))
          .toList();
      print('===============================================> cats: $cats');
      if (catModels.isEmpty) {
        emit(const CatListingEmptyState());
        return;
      }
      emit(CatListingLoadedState(cats: catModels));
    } catch (e) {
      emit(CatListingErrorState(message: e.toString()));
    }
  }

  Future<void> _onCatListingCreateCatEvent(
    CatListingCreateCatEvent event,
    Emitter<CatListingState> emit,
  ) async {
    // return emit(CatListingShowPaywallState());

    final user = _currentUserUsecase();
    if (user == null) {
      emit(const CatListingErrorState(message: 'User not authenticated'));
      return;
    }
    // event.context.router.push(const PaywallRoute());

    // return;

    final canCreateCat = await _catTrackingService.canCreateCat(
      userId: user.uid,
    );

    if (!canCreateCat) {
      // User has reached free cat limit, show paywall
      final purchasedSubscription = await event.context.router.push<bool>(
        const PaywallRoute(),
      );

      if (purchasedSubscription == false) {
        return;
      }
    }

    await event.context.router.push(const CreateCatRoute());
    // After returning from create cat page, fetch the cat list again
    add(const CatListingFetchCatsEvent());
  }
}
