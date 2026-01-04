import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/get_cats_usecase.dart';
import 'package:yucat/features/cat_listing/mappers/cat_entity_to_model_mapper.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';

part 'cat_listing_event.dart';
part 'cat_listing_state.dart';

class CatListingBloc extends Bloc<CatListingEvent, CatListingState> {
  final GetCatsUsecase _getCatsUsecase;
  final CatEntityToModelMapper _catEntityToModelMapper;
  final CurrentUserUsecase _currentUserUsecase;
  final LogScreenViewUsecase _logScreenViewUsecase;

  CatListingBloc({
    required GetCatsUsecase getCatsUsecase,
    required CatEntityToModelMapper catEntityToModelMapper,
    required CurrentUserUsecase currentUserUsecase,
    required LogScreenViewUsecase logScreenViewUsecase,
  }) : _getCatsUsecase = getCatsUsecase,
       _catEntityToModelMapper = catEntityToModelMapper,
       _currentUserUsecase = currentUserUsecase,
       _logScreenViewUsecase = logScreenViewUsecase,

       super(const CatListingLoadingState()) {
    on<CatListingInitialEvent>(_onCatListingInitialEvent);
    on<CatListingFetchCatsEvent>(_onCatListingFetchCatsEvent);
  }

  Future<void> _onCatListingInitialEvent(
    CatListingInitialEvent event,
    Emitter<CatListingState> emit,
  ) async {
    _logScreenViewUsecase.call(screenName: 'CatListingScreen');
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
      emit(CatListingLoadedState(cats: catModels));
    } catch (e) {
      emit(CatListingErrorState(message: e.toString()));
    }
  }
}
