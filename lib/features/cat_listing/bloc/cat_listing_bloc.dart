import 'package:auto_route/auto_route.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/get_cats_usecase.dart';
import 'package:yucat/features/cat_listing/mappers/cat_entity_to_model_mapper.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';
import 'package:yucat/features/health_carnet/domain/usecases/get_health_events_usecase.dart';
import 'package:yucat/features/health_carnet/presentation/models/cat_health_summary.dart';
import 'package:yucat/features/health_carnet/presentation/utils/cat_health_summary_resolver.dart';

part 'cat_listing_event.dart';
part 'cat_listing_state.dart';

class CatListingBloc extends Bloc<CatListingEvent, CatListingState> {
  final GetCatsUsecase _getCatsUsecase;
  final CatEntityToModelMapper _catEntityToModelMapper;
  final CurrentUserUsecase _currentUserUsecase;
  final GetHealthEventsUsecase _getHealthEventsUsecase;

  CatListingBloc({
    required GetCatsUsecase getCatsUsecase,
    required CatEntityToModelMapper catEntityToModelMapper,
    required CurrentUserUsecase currentUserUsecase,
    required GetHealthEventsUsecase getHealthEventsUsecase,
  }) : _getCatsUsecase = getCatsUsecase,
       _catEntityToModelMapper = catEntityToModelMapper,
       _currentUserUsecase = currentUserUsecase,
       _getHealthEventsUsecase = getHealthEventsUsecase,
       super(const CatListingLoadingState()) {
    on<CatListingInitialEvent>(_onCatListingInitialEvent);
    on<CatListingFetchCatsEvent>(_onCatListingFetchCatsEvent);
    on<CatListingCreateCatEvent>(_onCatListingCreateCatEvent);
  }

  Future<void> _onCatListingInitialEvent(
    CatListingInitialEvent event,
    Emitter<CatListingState> emit,
  ) async {
    add(const CatListingFetchCatsEvent());
  }

  Future<void> _onCatListingFetchCatsEvent(
    CatListingFetchCatsEvent event,
    Emitter<CatListingState> emit,
  ) async {
    // A refetch behind an already-loaded list (returning from detail) keeps
    // the cards on screen instead of flashing the skeleton.
    if (state is! CatListingLoadedState) {
      emit(const CatListingLoadingState());
    }
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
      if (catModels.isEmpty) {
        emit(const CatListingEmptyState());
        return;
      }
      // Cards first, pills when the carnet reads land. A refetch behind a
      // loaded list keeps the previous pills up until then rather than
      // flashing them away.
      final previous = switch (state) {
        CatListingLoadedState(:final health) => health,
        _ => const <String, CatHealthSummary>{},
      };
      emit(CatListingLoadedState(cats: catModels, health: previous));
      final summaries = await resolveHouseholdHealth(
        cats: cats,
        getHealthEvents: _getHealthEventsUsecase,
        now: DateTime.now(),
      );
      emit(CatListingLoadedState(
        cats: catModels,
        health: {
          for (final summary in summaries)
            if (summary.cat.id != null) summary.cat.id!: summary,
        },
      ));
    } catch (e) {
      emit(CatListingErrorState(message: e.toString()));
    }
  }

  Future<void> _onCatListingCreateCatEvent(
    CatListingCreateCatEvent event,
    Emitter<CatListingState> emit,
  ) async {
    final user = _currentUserUsecase();
    if (user == null) {
      emit(const CatListingErrorState(message: 'User not authenticated'));
      return;
    }

    await event.context.router.push(CreateCatRoute());
    // After returning from create cat page, fetch the cat list again
    add(const CatListingFetchCatsEvent());
  }
}
