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
import 'package:yucat/features/cat_listing/models/cat_model.dart';

part 'cat_detail_event.dart';
part 'cat_detail_state.dart';

class CatDetailBloc extends Bloc<CatDetailEvent, CatDetailState> {
  final DeleteCatUsecase _deleteCatUsecase;
  final UpdateCatPhotoUsecase _updateCatPhotoUsecase;
  final GetCatsUsecase _getCatsUsecase;
  final CurrentUserUsecase _currentUserUsecase;
  final CatEntityToModelMapper _catEntityToModelMapper;
  final LogEventUsecase _logEventUsecase;

  CatDetailBloc({
    required DeleteCatUsecase deleteCatUsecase,
    required UpdateCatPhotoUsecase updateCatPhotoUsecase,
    required GetCatsUsecase getCatsUsecase,
    required CurrentUserUsecase currentUserUsecase,
    required CatEntityToModelMapper catEntityToModelMapper,
    required LogEventUsecase logEventUsecase,
  })  : _deleteCatUsecase = deleteCatUsecase,
        _updateCatPhotoUsecase = updateCatPhotoUsecase,
        _getCatsUsecase = getCatsUsecase,
        _currentUserUsecase = currentUserUsecase,
        _catEntityToModelMapper = catEntityToModelMapper,
        _logEventUsecase = logEventUsecase,
        super(CatDetailInitialState()) {
    on<CatDetailInitialEvent>(_onCatDetailInitialEvent);
    on<CatDetailDeleteEvent>(_onCatDetailDeleteEvent);
    on<CatDetailEditEvent>(_onCatDetailEditEvent);
    on<CatDetailPhotoChangedEvent>(_onCatDetailPhotoChangedEvent);
    on<CatDetailReloadEvent>(_onCatDetailReloadEvent);
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

    emit(CatDetailLoadedState(cat: event.cat));
  }

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

    emit(CatDetailLoadedState(cat: event.cat, isUploadingPhoto: true));

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

      emit(CatDetailLoadedState(cat: event.cat.copyWith(profileImageUrl: url)));
    } catch (e) {
      debugPrint('Cat photo update failed: $e');
      emit(CatDetailPhotoErrorState());
      emit(CatDetailLoadedState(cat: event.cat));
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
          emit(CatDetailLoadedState(cat: _catEntityToModelMapper(cat)));
          return;
        }
      }
    } catch (e) {
      debugPrint('Cat detail reload failed: $e');
    }
  }
}
