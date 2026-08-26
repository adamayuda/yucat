import 'package:yucat/features/articles/domain/entities/article_entity.dart';
import 'package:yucat/features/articles/domain/repositories/articles_repository.dart';

class GetArticlesUsecase {
  final ArticlesRepository _repository;

  GetArticlesUsecase({required ArticlesRepository repository})
      : _repository = repository;

  Future<List<ArticleEntity>> call({String? language}) =>
      _repository.getArticles(language: language);
}
