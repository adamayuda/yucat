import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/get_cats_usecase.dart';
import 'package:yucat/features/cat_listing/presentation/mappers/cat_entity_to_model_mapper.dart';
import 'package:yucat/features/cat_listing/presentation/models/cat_model.dart';

part 'cat_listing_event.dart';
part 'cat_listing_state.dart';

class CatListingBloc extends Bloc<CatListingEvent, CatListingState> {
  final GetCatsUsecase _getCatsUsecase;
  final CatEntityToModelMapper _catEntityToModelMapper;
  final CurrentUserUsecase _currentUserUsecase;

  CatListingBloc({
    required GetCatsUsecase getCatsUsecase,
    required CatEntityToModelMapper catEntityToModelMapper,
    required CurrentUserUsecase currentUserUsecase,
  }) : _getCatsUsecase = getCatsUsecase,
       _catEntityToModelMapper = catEntityToModelMapper,
       _currentUserUsecase = currentUserUsecase,
       super(const CatListingLoadingState()) {
    on<CatListingInitialEvent>(_onCatListingInitialEvent);
    on<CatListingFetchCatsEvent>(_onCatListingFetchCatsEvent);
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
