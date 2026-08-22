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

  const RecipesLoadedState({
    required this.all,
    this.query = '',
    this.selectedCategory,
  });

  /// The filtered list the page renders. Computed here rather than stored so
  /// the state stays a single source of truth for `all` + the two filters.
  List<RecipeDisplayModel> get visible {
    final needle = query.trim().toLowerCase();
    return all.where((r) {
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
    );
  }

  @override
  List<Object?> get props => [all, query, selectedCategory];
}
