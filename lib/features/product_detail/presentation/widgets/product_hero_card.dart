import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/widgets/hatched_placeholder.dart';
import 'package:yucat/l10n/app_localizations.dart';

class _ComplementaryBadge extends StatelessWidget {
  final String foodType;

  const _ComplementaryBadge({required this.foodType});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = switch (foodType) {
      'topper' => l10n.productDetailComplementaryTopper,
      'supplement' => l10n.productDetailComplementarySupplement,
      _ => l10n.productDetailComplementaryTreat,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeXs,
        vertical: DSDimens.sizeXxxs,
      ),
      decoration: BoxDecoration(
        color: DSColors.tintSand,
        borderRadius: BorderRadius.circular(DSRadii.pill),
      ),
      child: Text(
        label,
        style: DSTextStyles.caption.copyWith(
          color: DSColors.inkPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ProductHeroCard extends StatelessWidget {
  final ProductDisplayModel product;
  final String? formatLine;

  const ProductHeroCard({
    super.key,
    required this.product,
    this.formatLine,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage =
        product.imageUrl != null && product.imageUrl!.isNotEmpty;
    final subtitle = formatLine == null || formatLine!.isEmpty
        ? product.brand
        : '${product.brand} · $formatLine';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          height: 96,
          child: hasImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(DSRadii.lg),
                  child: Container(
                    color: DSColors.tintLavender,
                    alignment: Alignment.center,
                    child: Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const HatchedPlaceholder(),
                    ),
                  ),
                )
              : const HatchedPlaceholder(),
        ),
        const SizedBox(width: DSDimens.sizeS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: DSTextStyles.displayLg.copyWith(fontSize: 26),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: DSDimens.sizeXxxs),
              Text(
                subtitle,
                style: DSTextStyles.bodyMd.copyWith(
                  color: DSColors.inkSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // A treat's 0–100 is "how good a treat", not "how good a
              // dinner" — say so before the score does the talking.
              if (product.isComplementary) ...[
                const SizedBox(height: DSDimens.sizeXxs),
                _ComplementaryBadge(foodType: product.foodType!),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
