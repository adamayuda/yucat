import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';
import 'package:yucat/features/product_detail/presentation/widgets/hatched_placeholder.dart';
import 'package:yucat/presentation/components/ds_card.dart';

/// A litter row for the saved-litters and litter-history lists.
///
/// One widget for both, unlike the food rows which are duplicated per feature —
/// the layout is identical, so there is nothing to gain from two copies.
class LitterListRow extends StatelessWidget {
  final LitterDisplayModel litter;
  final VoidCallback onTap;

  const LitterListRow({
    super.key,
    required this.litter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = litter.imageUrl != null && litter.imageUrl!.isNotEmpty;
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
                          litter.imageUrl!,
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
                    litter.name,
                    style: DSTextStyles.titleMd,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    litter.brand,
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
            // Hidden when the backend found nothing: score 0 is a "no data"
            // sentinel, and "0/100" reads as a damning grade.
            if (!litter.dataUnavailable)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSDimens.sizeXs,
                  vertical: DSDimens.sizeXxs,
                ),
                decoration: BoxDecoration(
                  color: DSColors.tintSky,
                  borderRadius: BorderRadius.circular(DSRadii.pill),
                ),
                child: Text(
                  litter.scoreDisplay,
                  style: DSTextStyles.caption.copyWith(
                    color: DSColors.inkPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
