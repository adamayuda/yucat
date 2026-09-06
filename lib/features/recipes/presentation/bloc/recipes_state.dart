part of 'recipes_bloc.dart';

sealed class RecipesState extends Equatable {
  const RecipesState();

  @override
  List<Object?> get props => [];
}

class RecipesLoadingState extends RecipesState {
  const RecipesLoadingState();
}

class RecipesErrorState extends RecipesState {
  const RecipesErrorState();
}

class RecipesLoadedState extends RecipesState {
  /// Every recipe the repository returned, unfiltered.
  final List<RecipeDisplayModel> all;
  final String query;
  final RecipeCategory? selectedCategory;

  /// Allergen keys declared across **all** of the user's cats. Empty when the
  /// caller did not opt into filtering, or when no cat declares anything.
  ///
  /// The union rather than one cat's list: a treat is made once and shared, so
  /// anything that would harm any cat in the house should not be suggested.
  final Set<String> excludedAllergens;

  const RecipesLoadedState({
    required this.all,
    this.query = '',
    this.selectedCategory,
    this.excludedAllergens = const {},
  });

  /// Everything not ruled out by a declared allergy. The base list for both
  /// [visible] and [hiddenByAllergies], so the two can't disagree.
  List<RecipeDisplayModel> get _allowed {
    if (excludedAllergens.isEmpty) return all;
    return all
        .where((r) => !r.allergenKeys.any(excludedAllergens.contains))
        .toList();
  }

  /// How many recipes the allergy filter removed, before any search or category
  /// filter. Surfaced in the UI: silently shrinking a catalogue would leave
  /// someone hunting for a recipe they remember seeing.
  int get hiddenByAllergies => all.length - _allowed.length;

  /// The filtered list the page renders. Computed here rather than stored so
  /// the state stays a single source of truth for `all` + the filters.
  List<RecipeDisplayModel> get visible {
    final needle = query.trim().toLowerCase();
    return _allowed.where((r) {
      if (selectedCategory != null && r.category != selectedCategory) {
        return false;
      }
      if (needle.isEmpty) return true;
      return r.searchHaystack.contains(needle);
    }).toList();
  }

  bool get isEmpty => visible.isEmpty;

  RecipesLoadedState copyWith({
    String? query,
    RecipeCategory? selectedCategory,
    bool clearCategory = false,
  }) {
    return RecipesLoadedState(
      all: all,
      query: query ?? this.query,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      excludedAllergens: excludedAllergens,
    );
  }

  @override
  List<Object?> get props =>
      [all, query, selectedCategory, excludedAllergens];
}
