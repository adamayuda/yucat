import 'package:flutter/material.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/features/product_detail/presentation/utils/verdict_headline.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/presentation/utils/cat_product_recommendations.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/widgets/hatched_placeholder.dart';
import 'package:yucat/presentation/components/ds_card.dart';

/// Presentational "Top picks" list. Each row shows the per-cat **fit** (not the
/// product's base quality score) plus the headline reason it was picked. Hidden
/// when [picks] is empty.
class ProductPicksList extends StatelessWidget {
  final String title;
  final List<ProductPick> picks;
  final ValueChanged<ProductPick> onTap;

  const ProductPicksList({
    super.key,
    required this.title,
    required this.picks,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (picks.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: DSTextStyles.titleMd),
        const SizedBox(height: DSDimens.sizeS),
        for (var i = 0; i < picks.length; i++) ...[
          if (i > 0) const SizedBox(height: DSDimens.sizeS),
          _PickRow(pick: picks[i], onTap: () => onTap(picks[i])),
        ],
      ],
    );
  }
}

class _PickRow extends StatelessWidget {
  final ProductPick pick;
  final VoidCallback onTap;

  const _PickRow({required this.pick, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final product = pick.product;
    return DSCard(
      onTap: onTap,
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Thumb(imageUrl: product.imageUrl),
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
                  style: DSTextStyles.bodyMd
                      .copyWith(color: DSColors.inkSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: DSDimens.sizeXxs),
                _QualityPill(product: product),
                if (pick.why != null) ...[
                  const SizedBox(height: DSDimens.sizeXxs),
                  _WhyChip(text: pick.why!),
                ],
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

/// The food's quality badge ("82 • Excellent"), coloured by its quality grade.
/// (Suitability for the cat is conveyed by the section heading + why-reason;
/// ranking still orders by per-cat fit.)
class _QualityPill extends StatelessWidget {
  final ProductDisplayModel product;

  const _QualityPill({required this.product});

  @override
  Widget build(BuildContext context) {
    final color = product.ratingColor;
    final rating = ratingLabelFor(
      product.ratingText,
      AppLocalizations.of(context),
    );
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
        '${product.score} • $rating',
        style: DSTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// The headline reason this product was picked for the cat.
class _WhyChip extends StatelessWidget {
  final String text;

  const _WhyChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.check_circle_rounded,
            size: 14,
            color: DSColors.accentSuccess,
          ),
        ),
        const SizedBox(width: DSDimens.sizeXxs),
        Expanded(
          child: Text(
            text,
            style: DSTextStyles.caption.copyWith(color: DSColors.inkSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? imageUrl;

  const _Thumb({required this.imageUrl});

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
