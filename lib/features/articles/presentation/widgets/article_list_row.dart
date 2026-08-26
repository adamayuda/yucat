import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/articles/presentation/models/article_display_model.dart';
import 'package:yucat/features/articles/presentation/widgets/article_meta.dart';
import 'package:yucat/presentation/components/ds_card.dart';

/// One row of the articles list: photo, title, "Category · N min".
class ArticleListRow extends StatelessWidget {
  final ArticleDisplayModel article;
  final VoidCallback onTap;

  const ArticleListRow({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DSCard(
      onTap: onTap,
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Thumb(imageUrl: article.imageUrl),
          const SizedBox(width: DSDimens.sizeS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: DSTextStyles.titleMd,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: DSDimens.sizeXxs),
                ArticleMetaRow(article: article),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? imageUrl;

  const _Thumb({required this.imageUrl});

  static const double _size = 80;

  @override
  Widget build(BuildContext context) {
    // Check for a URL first so an article with no photo never starts a network
    // request; the tint sits behind the image so there's no white flash.
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: DSColors.tintLavender,
        borderRadius: BorderRadius.circular(DSRadii.lg),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              width: _size,
              height: _size,
              errorBuilder: (_, __, ___) =>
                  const ArticleImagePlaceholder(size: 28),
            )
          : const ArticleImagePlaceholder(size: 28),
    );
  }
}
