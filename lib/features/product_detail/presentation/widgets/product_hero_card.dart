import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/widgets/hatched_placeholder.dart';
import 'package:yucat/l10n/app_localizations.dart';

class ProductHeroCard extends StatelessWidget {
  final ProductDisplayModel product;
  final String? formatLine;
  final bool aiIdentified;

  const ProductHeroCard({
    super.key,
    required this.product,
    this.formatLine,
    this.aiIdentified = false,
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
              if (aiIdentified) ...[
                _AiIdentifiedPill(),
                const SizedBox(height: DSDimens.sizeXxs),
              ],
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
            ],
          ),
        ),
      ],
    );
  }
}

class _AiIdentifiedPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeXs,
        vertical: DSDimens.sizeXxxs,
      ),
      decoration: BoxDecoration(
        color: DSColors.accentSuccessSoft,
        borderRadius: BorderRadius.circular(DSRadii.pill),
      ),
      child: Text(
        l10n.productDetailAiIdentifiedPill,
        style: DSTextStyles.caption.copyWith(
          color: DSColors.accentSuccess,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
