part of 'recipes_bloc.dart';

sealed class RecipesEvent extends Equatable {
  const RecipesEvent();

  @override
  List<Object?> get props => [];
}

class RecipesInitialEvent extends RecipesEvent {
  /// The app's resolved language code. Null or unsupported yields the
  /// canonical English copy.
  final String? language;

  const RecipesInitialEvent({this.language});

  @override
  List<Object?> get props => [language];
}

class RecipesQueryChanged extends RecipesEvent {
  final String query;

  const RecipesQueryChanged({required this.query});

  @override
  List<Object?> get props => [query];
}

class RecipesCategorySelected extends RecipesEvent {
  /// `null` means the "All" chip.
  final RecipeCategory? category;

  const RecipesCategorySelected({required this.category});

  @override
  List<Object?> get props => [category];
}
