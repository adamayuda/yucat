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

  /// Hide recipes containing an allergen any of the user's cats reacts to.
  ///
  /// Opt-in rather than always-on, because it costs a cat fetch. The Recipes
  /// **tab** asks for it — that is where someone chooses what to cook. Home's
  /// swimlane does not: it is a discovery surface that already avoids per-cat
  /// data, and adding a second cat read to every Home load would be a real cost
  /// for six teaser cards. ⚠️ The consequence is that the lane can show a recipe
  /// the tab hides; tapping through still opens it.
  final bool excludeCatAllergens;

  const RecipesInitialEvent({
    this.language,
    this.excludeCatAllergens = false,
  });

  @override
  List<Object?> get props => [language, excludeCatAllergens];
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
