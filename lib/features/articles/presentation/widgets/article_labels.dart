import 'package:yucat/features/articles/domain/entities/article_entity.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// Localized copy for [ArticleCategory]. Kept in one place so the filter chips,
/// the detail screen's pill and the list row can't drift apart.
extension ArticleCategoryL10n on ArticleCategory {
  String label(AppLocalizations l10n) => switch (this) {
        ArticleCategory.nutrition => l10n.articlesCategoryNutrition,
        ArticleCategory.health => l10n.articlesCategoryHealth,
        ArticleCategory.behaviour => l10n.articlesCategoryBehaviour,
        ArticleCategory.other => l10n.articlesCategoryOther,
      };
}
