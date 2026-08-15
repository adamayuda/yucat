import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/saved_products/domain/usecases/is_litter_saved_usecase.dart';
import 'package:yucat/features/saved_products/domain/usecases/save_litter_usecase.dart';
import 'package:yucat/features/saved_products/domain/usecases/unsave_litter_usecase.dart';
import '../models/litter_display_model.dart';

part 'litter_detail_event.dart';
part 'litter_detail_state.dart';

class LitterDetailBloc extends Bloc<LitterDetailEvent, LitterDetailState> {
  final LogEventUsecase _logEventUsecase;
  final IsLitterSavedUsecase _isLitterSavedUsecase;
  final SaveLitterUsecase _saveLitterUsecase;
  final UnsaveLitterUsecase _unsaveLitterUsecase;

  LitterDetailBloc({
    required LogEventUsecase logEventUsecase,
    required IsLitterSavedUsecase isLitterSavedUsecase,
    required SaveLitterUsecase saveLitterUsecase,
    required UnsaveLitterUsecase unsaveLitterUsecase,
  })  : _logEventUsecase = logEventUsecase,
        _isLitterSavedUsecase = isLitterSavedUsecase,
        _saveLitterUsecase = saveLitterUsecase,
        _unsaveLitterUsecase = unsaveLitterUsecase,
        super(LitterDetailHiddenState()) {
    on<LitterDetailInitialEvent>(_onInitial);
    on<LitterDetailToggleSavedEvent>(_onToggleSaved);
  }

  Future<void> _onInitial(
    LitterDetailInitialEvent event,
    Emitter<LitterDetailState> emit,
  ) async {
    final litter = event.litter;
    if (litter == null) {
      emit(LitterDetailErrorState());
      return;
    }

    _logEventUsecase.call(
      eventName: AnalyticsEvents.litterDetailViewed,
      properties: {
        'litter_name': litter.name,
        'litter_brand': litter.brand,
        'litter_material': litter.material.wire,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    final isSaved = await _isLitterSavedUsecase(litter);
    emit(LitterDetailLoadedState(litter: litter, isSaved: isSaved));
  }

  Future<void> _onToggleSaved(
    LitterDetailToggleSavedEvent event,
    Emitter<LitterDetailState> emit,
  ) async {
    final current = state;
    if (current is! LitterDetailLoadedState) return;

    final nextSaved = !current.isSaved;
    if (nextSaved) {
      await _saveLitterUsecase(current.litter);
    } else {
      await _unsaveLitterUsecase(current.litter);
    }
    _logEventUsecase.call(
      eventName: nextSaved
          ? AnalyticsEvents.litterSaved
          : AnalyticsEvents.litterUnsaved,
      properties: {
        'litter_name': current.litter.name,
        'litter_brand': current.litter.brand,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    emit(current.copyWith(isSaved: nextSaved));
  }
}
