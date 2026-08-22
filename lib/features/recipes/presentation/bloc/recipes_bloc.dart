import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/features/recipes/domain/entities/recipe_entity.dart';
import 'package:yucat/features/recipes/domain/usecases/get_recipes_usecase.dart';
import 'package:yucat/features/recipes/presentation/mappers/recipe_entity_to_model_mapper.dart';
import 'package:yucat/features/recipes/presentation/models/recipe_display_model.dart';

part 'recipes_event.dart';
part 'recipes_state.dart';

class RecipesBloc extends Bloc<RecipesEvent, RecipesState> {
  final GetRecipesUsecase _getRecipesUsecase;
  final RecipeEntityToModelMapper _mapper;

  RecipesBloc({
    required GetRecipesUsecase getRecipesUsecase,
    required RecipeEntityToModelMapper mapper,
  })  : _getRecipesUsecase = getRecipesUsecase,
        _mapper = mapper,
        super(const RecipesLoadingState()) {
    on<RecipesInitialEvent>(_onInitial);
    on<RecipesQueryChanged>(_onQueryChanged);
    on<RecipesCategorySelected>(_onCategorySelected);
  }

  Future<void> _onInitial(
    RecipesInitialEvent event,
    Emitter<RecipesState> emit,
  ) async {
    emit(const RecipesLoadingState());
    try {
      final recipes = await _getRecipesUsecase(language: event.language);
      emit(RecipesLoadedState(all: recipes.map(_mapper.call).toList()));
    } catch (_) {
      emit(const RecipesErrorState());
    }
  }

  // NOTE: no debounce, deliberately. SearchBloc debounces because every
  // keystroke would hit Algolia; recipes are already in memory, so filtering is
  // instant and a delay would only make typing feel laggy.
  void _onQueryChanged(
    RecipesQueryChanged event,
    Emitter<RecipesState> emit,
  ) {
    final current = state;
    if (current is! RecipesLoadedState) return;
    emit(current.copyWith(query: event.query));
  }

  void _onCategorySelected(
    RecipesCategorySelected event,
    Emitter<RecipesState> emit,
  ) {
    final current = state;
    if (current is! RecipesLoadedState) return;
    emit(
      current.copyWith(
        selectedCategory: event.category,
        clearCategory: event.category == null,
      ),
    );
  }
}
