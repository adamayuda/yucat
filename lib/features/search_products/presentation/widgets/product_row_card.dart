import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/widgets/hatched_placeholder.dart';
import 'package:yucat/presentation/components/ds_card.dart';

class ProductRowCard extends StatelessWidget {
  final ProductDisplayModel product;
  final VoidCallback onTap;

  const ProductRowCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DSCard(
      onTap: onTap,
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Row(
        children: [
          _ProductThumb(imageUrl: product.imageUrl),
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
                const SizedBox(height: DSDimens.sizeXxxs),
                Text(
                  product.brand,
                  style: DSTextStyles.bodyMd.copyWith(
                    color: DSColors.inkSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: DSDimens.sizeXxs),
                _ScorePill(
                  score: product.scoreDisplay,
                  rating: product.ratingText,
                  color: product.ratingColor,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: DSColors.inkTertiary,
            size: 24,
          ),
        ],
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  final String? imageUrl;

  const _ProductThumb({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Container(
      width: 64,
      height: 64,
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
              errorBuilder: (_, __, ___) => const HatchedPlaceholder(),
            )
          : const HatchedPlaceholder(),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String score;
  final String rating;
  final ProductRatingColor color;

  const _ScorePill({
    required this.score,
    required this.rating,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (color) {
      ProductRatingColor.green => (
        DSColors.accentSuccessSoft,
        DSColors.accentSuccess,
      ),
      ProductRatingColor.yellow => (
        const Color(0xFFFFF3D6),
        const Color(0xFFB37800),
      ),
      ProductRatingColor.red => (DSColors.coralSurface, DSColors.accentDanger),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeXs,
        vertical: DSDimens.sizeXxxs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(DSRadii.pill),
      ),
      child: Text(
        '$score • $rating',
        style: DSTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
