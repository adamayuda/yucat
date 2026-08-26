import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/articles/presentation/models/article_display_model.dart';
import 'package:yucat/features/articles/presentation/widgets/article_meta.dart';
import 'package:yucat/presentation/components/ds_card.dart';

/// Vertical article tile for the Home lane: photo above the title and meta.
///
/// The sibling [ArticleListRow] is a `Row` with an unconstrained `Expanded`, so
/// it can't live in a horizontal lane — this is the poster variant, mirroring
/// `RecipePosterCard`.
class ArticlePosterCard extends StatelessWidget {
  final ArticleDisplayModel article;
  final VoidCallback onTap;

  const ArticlePosterCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  static const double width = 208;
  static const double _imageHeight = 124;

  /// Height of the text block: `sizeS` padding top and bottom, two lines of
  /// `titleMd` (24 each), the gap, and one line of `bodyMd` (20).
  ///
  /// Derived rather than eyeballed — an earlier hardcoded 92 was 12px short and
  /// overflowed every card. If either text style's `height` changes, this must
  /// change with it.
  static const double _textBlockHeight =
      DSDimens.sizeS * 2 + (24 * 2) + DSDimens.sizeXxxs + 20;

  /// Lane height this card needs: image + the title/meta block below it.
  static const double laneHeight = _imageHeight + _textBlockHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DSCard(
        // DSCard already clips to DSRadii.xl, so the photo gets rounded top
        // corners without a ClipRRect of its own.
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PosterImage(imageUrl: article.imageUrl),
            // Expanded + Flexible so a larger accessibility text size costs the
            // title a line rather than overflowing the fixed lane height.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(DSDimens.sizeS),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        article.title,
                        style: DSTextStyles.titleMd,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: DSDimens.sizeXxxs),
                    ArticleMetaRow(article: article),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PosterImage extends StatelessWidget {
  final String? imageUrl;

  const _PosterImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Container(
      width: double.infinity,
      height: ArticlePosterCard._imageHeight,
      color: DSColors.tintLavender,
      alignment: Alignment.center,
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: ArticlePosterCard._imageHeight,
              errorBuilder: (_, __, ___) =>
                  const ArticleImagePlaceholder(size: 36),
            )
          : const ArticleImagePlaceholder(size: 36),
    );
  }
}
