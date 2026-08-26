import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/articles/domain/entities/article_entity.dart';
import 'package:yucat/features/articles/presentation/models/article_display_model.dart';
import 'package:yucat/features/articles/presentation/widgets/article_labels.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// "Health · 3 min" — the one-line subtitle under an article's title.
///
/// Shared by the list row and the Home lane card so the two can't drift.
class ArticleMetaRow extends StatelessWidget {
  final ArticleDisplayModel article;

  const ArticleMetaRow({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Text(
      '${article.category.label(l10n)}  ·  '
      '${l10n.articlesReadMinutes(article.readMinutes)}',
      style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkTertiary),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// The category as a soft blue pill — the detail screen's badge above the
/// headline.
///
/// Blue rather than per-category colours: an article's category is a label, not
/// a severity, so it should read as one consistent chip. (Contrast
/// `FoodSafetyPill`, where the colour *is* the information.)
class ArticleCategoryPill extends StatelessWidget {
  final ArticleCategory category;

  const ArticleCategoryPill({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeS,
        vertical: DSDimens.sizeXxs,
      ),
      decoration: BoxDecoration(
        color: DSColors.tintBlueSoft,
        borderRadius: BorderRadius.circular(DSRadii.pill),
      ),
      child: Text(
        category.label(l10n),
        style: DSTextStyles.label.copyWith(
          color: DSColors.accentInfo,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// The stand-in when an article has no photo, or its photo fails to load.
///
/// Deliberately not `HatchedPlaceholder`: that paints a "no image" tag, right
/// for a product whose lookup failed and wrong for an article that simply has
/// no photo yet.
class ArticleImagePlaceholder extends StatelessWidget {
  final double size;

  const ArticleImagePlaceholder({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.article_outlined,
        color: DSColors.inkTertiary,
        size: size,
      ),
    );
  }
}
