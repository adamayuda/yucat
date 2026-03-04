import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/delete_cat_usecase.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';

part 'cat_detail_event.dart';
part 'cat_detail_state.dart';

class CatDetailBloc extends Bloc<CatDetailEvent, CatDetailState> {
  final DeleteCatUsecase _deleteCatUsecase;
  final LogScreenViewUsecase _logScreenViewUsecase;
  final LogEventUsecase _logEventUsecase;

  CatDetailBloc({
    required DeleteCatUsecase deleteCatUsecase,
    required LogScreenViewUsecase logScreenViewUsecase,
    required LogEventUsecase logEventUsecase,
  })  : _deleteCatUsecase = deleteCatUsecase,
        _logScreenViewUsecase = logScreenViewUsecase,
        _logEventUsecase = logEventUsecase,
        super(CatDetailInitialState()) {
    on<CatDetailInitialEvent>(_onCatDetailInitialEvent);
    on<CatDetailDeleteEvent>(_onCatDetailDeleteEvent);
    on<CatDetailEditEvent>(_onCatDetailEditEvent);
  }

  Future<void> _onCatDetailInitialEvent(
    CatDetailInitialEvent event,
    Emitter<CatDetailState> emit,
  ) async {
    _logEventUsecase.call(
      eventName: 'Cat Profile Viewed',
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
        eventName: 'Cat Profile Deleted',
        properties: {
          'cat_id': event.catId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      emit(CatDetailDeletedState());
    } catch (e) {
      _logEventUsecase.call(
        eventName: 'Cat Profile Delete Failed',
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
      eventName: 'Cat Profile Edit Started',
      properties: {
        'cat_name': event.cat.name,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    emit(CatDetailNavigateToEditState(cat: event.cat));
  }
}
