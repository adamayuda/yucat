import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/widgets/hatched_placeholder.dart';
import 'package:yucat/features/product_detail/presentation/widgets/ring_score.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

/// Preview of the most recently saved products on Home. Each row shows the
/// product's overall score (the same number shown on the product page).
class SavedProductsPreviewSection extends StatelessWidget {
  static const int _previewCount = 3;

  final List<ProductDisplayModel> savedProducts;
  final ValueChanged<ProductDisplayModel> onProductTap;
  final VoidCallback onSeeAll;

  const SavedProductsPreviewSection({
    super.key,
    required this.savedProducts,
    required this.onProductTap,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final hasSaved = savedProducts.isNotEmpty;
    final preview = savedProducts.take(_previewCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text('Saved products', style: DSTextStyles.displayLg),
            ),
            if (hasSaved)
              DSTextLink(label: 'See all', onPressed: onSeeAll),
          ],
        ),
        const SizedBox(height: DSDimens.sizeS),
        if (!hasSaved)
          const _EmptyCard()
        else
          for (var i = 0; i < preview.length; i++) ...[
            if (i > 0) const SizedBox(height: DSDimens.sizeS),
            _SavedProductRow(
              product: preview[i],
              onTap: () => onProductTap(preview[i]),
            ),
          ],
      ],
    );
  }
}

class _SavedProductRow extends StatelessWidget {
  final ProductDisplayModel product;
  final VoidCallback onTap;

  const _SavedProductRow({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = product.imageUrl != null && product.imageUrl!.isNotEmpty;

    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSRadii.lg),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(DSRadii.md),
                child: hasImage
                    ? Container(
                        color: DSColors.tintLavender,
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const HatchedPlaceholder(),
                        ),
                      )
                    : const HatchedPlaceholder(),
              ),
            ),
            const SizedBox(width: DSDimens.sizeS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: DSTextStyles.titleMd,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.brand,
                    style: DSTextStyles.bodyMd.copyWith(
                      color: DSColors.inkSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: DSDimens.sizeS),
            RingScore(
              score: product.score,
              maxScore: product.maxScore,
              ratingColor: product.ratingColor,
              size: 44,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: DSColors.tintSky,
              borderRadius: BorderRadius.circular(DSRadii.md),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.bookmark_border_rounded,
              color: DSColors.accentInfo,
              size: 24,
            ),
          ),
          const SizedBox(width: DSDimens.sizeS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No saved products yet', style: DSTextStyles.titleMd),
                const SizedBox(height: 2),
                Text(
                  'Tap the bookmark on a product to save it here.',
                  style: DSTextStyles.bodyMd.copyWith(
                    color: DSColors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
