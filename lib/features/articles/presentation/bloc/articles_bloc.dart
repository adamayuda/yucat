import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/features/articles/domain/entities/article_entity.dart';
import 'package:yucat/features/articles/domain/usecases/get_articles_usecase.dart';
import 'package:yucat/features/articles/presentation/mappers/article_entity_to_model_mapper.dart';
import 'package:yucat/features/articles/presentation/models/article_display_model.dart';

part 'articles_event.dart';
part 'articles_state.dart';

class ArticlesBloc extends Bloc<ArticlesEvent, ArticlesState> {
  final GetArticlesUsecase _getArticlesUsecase;
  final ArticleEntityToModelMapper _mapper;

  ArticlesBloc({
    required GetArticlesUsecase getArticlesUsecase,
    required ArticleEntityToModelMapper mapper,
  })  : _getArticlesUsecase = getArticlesUsecase,
        _mapper = mapper,
        super(const ArticlesLoadingState()) {
    on<ArticlesInitialEvent>(_onInitial);
    on<ArticlesQueryChanged>(_onQueryChanged);
    on<ArticlesCategorySelected>(_onCategorySelected);
  }

  Future<void> _onInitial(
    ArticlesInitialEvent event,
    Emitter<ArticlesState> emit,
  ) async {
    emit(const ArticlesLoadingState());
    try {
      final articles = await _getArticlesUsecase(language: event.language);
      emit(ArticlesLoadedState(all: articles.map(_mapper.call).toList()));
    } catch (_) {
      emit(const ArticlesErrorState());
    }
  }

  // NOTE: no debounce, deliberately. SearchBloc debounces because every
  // keystroke would hit Algolia; articles are already in memory, so filtering
  // is instant and a delay would only make typing feel laggy.
  void _onQueryChanged(
    ArticlesQueryChanged event,
    Emitter<ArticlesState> emit,
  ) {
    final current = state;
    if (current is! ArticlesLoadedState) return;
    emit(current.copyWith(query: event.query));
  }

  void _onCategorySelected(
    ArticlesCategorySelected event,
    Emitter<ArticlesState> emit,
  ) {
    final current = state;
    if (current is! ArticlesLoadedState) return;
    emit(
      current.copyWith(
        selectedCategory: event.category,
        clearCategory: event.category == null,
      ),
    );
  }
}
