part of 'articles_bloc.dart';

sealed class ArticlesEvent extends Equatable {
  const ArticlesEvent();

  @override
  List<Object?> get props => [];
}

class ArticlesInitialEvent extends ArticlesEvent {
  /// The app's resolved language code. Null or unsupported yields the
  /// canonical English copy.
  final String? language;

  const ArticlesInitialEvent({this.language});

  @override
  List<Object?> get props => [language];
}

class ArticlesQueryChanged extends ArticlesEvent {
  final String query;

  const ArticlesQueryChanged({required this.query});

  @override
  List<Object?> get props => [query];
}

class ArticlesCategorySelected extends ArticlesEvent {
  /// `null` means the "All" chip.
  final ArticleCategory? category;

  const ArticlesCategorySelected({required this.category});

  @override
  List<Object?> get props => [category];
}
