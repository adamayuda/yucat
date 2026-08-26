part of 'articles_bloc.dart';

sealed class ArticlesState extends Equatable {
  const ArticlesState();

  @override
  List<Object?> get props => [];
}

class ArticlesLoadingState extends ArticlesState {
  const ArticlesLoadingState();
}

class ArticlesErrorState extends ArticlesState {
  const ArticlesErrorState();
}

class ArticlesLoadedState extends ArticlesState {
  /// Every article the repository returned, unfiltered and in authored order.
  ///
  /// ⚠️ Home's news card reads **this**, not [visible] — it shows the first
  /// article regardless of any filter the list screen has set.
  final List<ArticleDisplayModel> all;
  final String query;
  final ArticleCategory? selectedCategory;

  const ArticlesLoadedState({
    required this.all,
    this.query = '',
    this.selectedCategory,
  });

  /// The filtered list the list screen renders. Computed here rather than
  /// stored so the state stays a single source of truth for `all` + the two
  /// filters.
  List<ArticleDisplayModel> get visible {
    final needle = query.trim().toLowerCase();
    return all.where((a) {
      if (selectedCategory != null && a.category != selectedCategory) {
        return false;
      }
      if (needle.isEmpty) return true;
      return a.searchHaystack.contains(needle);
    }).toList();
  }

  bool get isEmpty => visible.isEmpty;

  ArticlesLoadedState copyWith({
    String? query,
    ArticleCategory? selectedCategory,
    bool clearCategory = false,
  }) {
    return ArticlesLoadedState(
      all: all,
      query: query ?? this.query,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
    );
  }

  @override
  List<Object?> get props => [all, query, selectedCategory];
}
