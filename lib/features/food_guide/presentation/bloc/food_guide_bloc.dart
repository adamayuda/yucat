import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/features/food_guide/domain/usecases/get_food_guide_usecase.dart';
import 'package:yucat/features/food_guide/presentation/mappers/food_guide_entity_to_model_mapper.dart';
import 'package:yucat/features/food_guide/presentation/models/food_guide_display_model.dart';

part 'food_guide_event.dart';
part 'food_guide_state.dart';

class FoodGuideBloc extends Bloc<FoodGuideEvent, FoodGuideState> {
  final GetFoodGuideUsecase _getFoodGuideUsecase;
  final FoodGuideEntityToModelMapper _mapper;

  FoodGuideBloc({
    required GetFoodGuideUsecase getFoodGuideUsecase,
    required FoodGuideEntityToModelMapper mapper,
  })  : _getFoodGuideUsecase = getFoodGuideUsecase,
        _mapper = mapper,
        super(const FoodGuideLoadingState()) {
    on<FoodGuideInitialEvent>(_onInitial);
  }

  Future<void> _onInitial(
    FoodGuideInitialEvent event,
    Emitter<FoodGuideState> emit,
  ) async {
    emit(const FoodGuideLoadingState());
    try {
      final items = await _getFoodGuideUsecase(language: event.language);
      emit(FoodGuideLoadedState(items: items.map(_mapper.call).toList()));
    } catch (_) {
      emit(const FoodGuideErrorState());
    }
  }
}
