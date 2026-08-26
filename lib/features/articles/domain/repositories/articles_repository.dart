import 'package:yucat/features/articles/domain/entities/article_entity.dart';

abstract class ArticlesRepository {
  /// [language] is the app's resolved language code; an unsupported or null
  /// value yields the canonical English copy.
  Future<List<ArticleEntity>> getArticles({String? language});
}
