part of 'food_guide_bloc.dart';

sealed class FoodGuideState extends Equatable {
  const FoodGuideState();

  @override
  List<Object?> get props => [];
}

class FoodGuideLoadingState extends FoodGuideState {
  const FoodGuideLoadingState();
}

class FoodGuideErrorState extends FoodGuideState {
  const FoodGuideErrorState();
}

class FoodGuideLoadedState extends FoodGuideState {
  /// Every published category the repository returned, in authored order.
  ///
  /// There is no filtering counterpart to `RecipesLoadedState.visible` — the
  /// guide has no search or category chips, so the list the lane renders is
  /// this one.
  final List<FoodGuideDisplayModel> items;

  const FoodGuideLoadedState({required this.items});

  @override
  List<Object?> get props => [items];
}
