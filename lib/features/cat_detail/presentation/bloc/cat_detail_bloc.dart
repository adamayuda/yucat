import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/delete_cat_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/get_cats_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/update_cat_photo_usecase.dart';
import 'package:yucat/features/cat_listing/mappers/cat_entity_to_model_mapper.dart';
import 'package:yucat/features/cat_listing/mappers/cat_model_to_entity.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';
import 'package:yucat/features/health_carnet/domain/usecases/get_health_events_usecase.dart';
import 'package:yucat/features/health_carnet/presentation/models/cat_health_summary.dart';
import 'package:yucat/features/health_carnet/presentation/utils/cat_health_summary_resolver.dart';

part 'cat_detail_event.dart';
part 'cat_detail_state.dart';

class CatDetailBloc extends Bloc<CatDetailEvent, CatDetailState> {
  final DeleteCatUsecase _deleteCatUsecase;
  final UpdateCatPhotoUsecase _updateCatPhotoUsecase;
  final GetCatsUsecase _getCatsUsecase;
  final CurrentUserUsecase _currentUserUsecase;
  final CatEntityToModelMapper _catEntityToModelMapper;
  final GetHealthEventsUsecase _getHealthEventsUsecase;
  final LogEventUsecase _logEventUsecase;

  CatDetailBloc({
    required DeleteCatUsecase deleteCatUsecase,
    required UpdateCatPhotoUsecase updateCatPhotoUsecase,
    required GetCatsUsecase getCatsUsecase,
    required CurrentUserUsecase currentUserUsecase,
    required CatEntityToModelMapper catEntityToModelMapper,
    required GetHealthEventsUsecase getHealthEventsUsecase,
    required LogEventUsecase logEventUsecase,
  })  : _deleteCatUsecase = deleteCatUsecase,
        _updateCatPhotoUsecase = updateCatPhotoUsecase,
        _getCatsUsecase = getCatsUsecase,
        _currentUserUsecase = currentUserUsecase,
        _catEntityToModelMapper = catEntityToModelMapper,
        _getHealthEventsUsecase = getHealthEventsUsecase,
        _logEventUsecase = logEventUsecase,
        super(CatDetailInitialState()) {
    on<CatDetailInitialEvent>(_onCatDetailInitialEvent);
    on<CatDetailDeleteEvent>(_onCatDetailDeleteEvent);
    on<CatDetailEditEvent>(_onCatDetailEditEvent);
    on<CatDetailPhotoChangedEvent>(_onCatDetailPhotoChangedEvent);
    on<CatDetailReloadEvent>(_onCatDetailReloadEvent);
    on<CatDetailHealthRefreshEvent>(_onCatDetailHealthRefreshEvent);
  }

  Future<void> _onCatDetailInitialEvent(
    CatDetailInitialEvent event,
    Emitter<CatDetailState> emit,
  ) async {
    _logEventUsecase.call(
      eventName: AnalyticsEvents.catProfileViewed,
      properties: {
        'cat_name': event.cat.name,
        'cat_age_group': event.cat.ageGroup ?? 'unknown',
        'cat_breed': event.cat.breed ?? 'unknown',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // The cat renders at once; the carnet row fills in when its read lands.
    // This bloc is root-provided, so `health: null` here also stops the
    // previous cat's summary showing on this one for a frame.
    emit(CatDetailLoadedState(cat: event.cat));
    await _emitHealth(emit);
  }

  /// Resolves the carnet summary for whatever cat the page currently shows
  /// and attaches it. Reads through `health_events_cache.dart`, so a return
  /// from the carnet — which refreshes the mirror on every write — costs no
  /// Firestore read. Null (a failed read) leaves the row on its neutral copy.
  ///
  /// Re-reads `state` after the await rather than trusting the event's cat:
  /// a photo change or reload may have emitted meanwhile, and this must not
  /// put the older model back.
  Future<void> _emitHealth(Emitter<CatDetailState> emit) async {
    final current = state;
    if (current is! CatDetailLoadedState) return;
    final health = await resolveCatHealth(
      cat: catEntityFromModel(current.cat),
      getHealthEvents: _getHealthEventsUsecase,
      now: DateTime.now(),
    );
    final latest = state;
    if (latest is! CatDetailLoadedState || latest.cat.id != current.cat.id) {
      return;
    }
    emit(latest.copyWith(health: health, clearHealth: health == null));
  }

  Future<void> _onCatDetailHealthRefreshEvent(
    CatDetailHealthRefreshEvent event,
    Emitter<CatDetailState> emit,
  ) =>
      _emitHealth(emit);

  Future<void> _onCatDetailDeleteEvent(
    CatDetailDeleteEvent event,
    Emitter<CatDetailState> emit,
  ) async {
    emit(CatDetailLoadingState());

    try {
      await _deleteCatUsecase.call(catId: event.catId);

      _logEventUsecase.call(
        eventName: AnalyticsEvents.catProfileDeleted,
        properties: {
          'cat_id': event.catId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      emit(CatDetailDeletedState());
    } catch (e) {
      _logEventUsecase.call(
        eventName: AnalyticsEvents.catProfileDeleteFailed,
        properties: {
          'cat_id': event.catId,
          'error_message': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      emit(CatDetailErrorState(message: 'Failed to delete cat: $e'));
    }
  }

  Future<void> _onCatDetailEditEvent(
    CatDetailEditEvent event,
    Emitter<CatDetailState> emit,
  ) async {
    _logEventUsecase.call(
      eventName: AnalyticsEvents.catProfileEditStarted,
      properties: {
        'cat_name': event.cat.name,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    emit(CatDetailNavigateToEditState(cat: event.cat));
  }

  /// Uploads the picked photo and swaps the URL on the loaded model. Emits the
  /// same `Cat Profile Updated` the wizard does, with `fields_changed` narrowed
  /// to the photo and a `source` so the two paths can be told apart.
  Future<void> _onCatDetailPhotoChangedEvent(
    CatDetailPhotoChangedEvent event,
    Emitter<CatDetailState> emit,
  ) async {
    final catId = event.cat.id;
    if (catId == null) return;

    final health = switch (state) {
      CatDetailLoadedState(:final health) => health,
      _ => null,
    };
    emit(CatDetailLoadedState(
      cat: event.cat,
      isUploadingPhoto: true,
      health: health,
    ));

    try {
      final url = await _updateCatPhotoUsecase.call(
        catId: catId,
        imageFile: event.photo,
        previousImageUrl: event.cat.profileImageUrl,
      );

      _logEventUsecase.call(
        eventName: AnalyticsEvents.catProfileUpdated,
        properties: {
          'cat_name': event.cat.name,
          'cat_age_group': event.cat.ageGroup ?? 'unknown',
          'cat_breed': event.cat.breed ?? 'unknown',
          'fields_changed': const ['profileImage'],
          'source': 'cat_detail',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      emit(CatDetailLoadedState(
        cat: event.cat.copyWith(profileImageUrl: url),
        health: health,
      ));
    } catch (e) {
      debugPrint('Cat photo update failed: $e');
      emit(CatDetailPhotoErrorState());
      emit(CatDetailLoadedState(cat: event.cat, health: health));
    }
  }

  /// Re-fetches the user's cats and swaps in the matching one. Any failure —
  /// signed out, network, cat gone — leaves the current state untouched: the
  /// page already has *a* cat to show, and a stale one beats an error screen
  /// for a refresh the user never asked for.
  Future<void> _onCatDetailReloadEvent(
    CatDetailReloadEvent event,
    Emitter<CatDetailState> emit,
  ) async {
    final user = _currentUserUsecase();
    if (user == null) return;
    try {
      final cats = await _getCatsUsecase(userId: user.uid);
      for (final cat in cats) {
        if (cat.id == event.catId) {
          final health = switch (state) {
            CatDetailLoadedState(:final health) => health,
            _ => null,
          };
          emit(CatDetailLoadedState(
            cat: _catEntityToModelMapper(cat),
            health: health,
          ));
          // An edit can change age or neutered status, which moves the
          // schedule; re-derive from the (cached) records.
          await _emitHealth(emit);
          return;
        }
      }
    } catch (e) {
      debugPrint('Cat detail reload failed: $e');
    }
  }
}
