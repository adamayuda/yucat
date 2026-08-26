import 'package:yucat/features/articles/domain/entities/article_entity.dart';
import 'package:yucat/features/articles/presentation/models/article_display_model.dart';

class ArticleEntityToModelMapper {
  const ArticleEntityToModelMapper();

  ArticleDisplayModel call(ArticleEntity entity) => ArticleDisplayModel(
        id: entity.id,
        title: entity.title,
        excerpt: entity.excerpt,
        body: entity.body,
        category: entity.category,
        readMinutes: entity.readMinutes,
        imageUrl: entity.imageUrl,
      );
}
