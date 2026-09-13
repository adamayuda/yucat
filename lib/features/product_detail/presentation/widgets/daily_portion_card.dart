import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/utils/daily_portion.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';

/// "≈ 210 kcal a day · ≈ 245 g · ≈ 2.9 × 85g pouch" for the selected cat.
/// For a treat it shows the 10 % budget instead. Hidden when the product has
/// no usable energy; a cat without a weight gets a nudge to add one.
class DailyPortionCard extends StatelessWidget {
  final CatEntity cat;
  final ProductDisplayModel product;

  const DailyPortionCard({super.key, required this.cat, required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (product.dataUnavailable || product.calories <= 0) {
      return const SizedBox.shrink();
    }
    final portion = computeDailyPortion(cat, product);

    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.productDetailPortionTitle(cat.name),
            style: DSTextStyles.caption.copyWith(
              color: DSColors.inkSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: DSDimens.sizeXs),
          if (portion == null)
            Text(
              l10n.productDetailPortionNeedsWeight(cat.name),
              style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkSecondary),
            )
          else ...[
            if (portion.isTreatBudget)
              Text(
                l10n.productDetailPortionTreatBudget(
                  (portion.kcalPerDay * treatBudgetShare).round(),
                  portion.gramsPerDay,
                ),
                style: DSTextStyles.bodyMd,
              )
            else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.productDetailPortionGrams(portion.gramsPerDay),
                    style: DSTextStyles.headlineMd,
                  ),
                  const SizedBox(width: DSDimens.sizeXs),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      l10n.productDetailPortionKcal(portion.kcalPerDay),
                      style: DSTextStyles.bodyMd
                          .copyWith(color: DSColors.inkSecondary),
                    ),
                  ),
                ],
              ),
              if (portion.unitsPerDay != null) ...[
                const SizedBox(height: DSDimens.sizeXxs),
                Text(
                  l10n.productDetailPortionUnits(
                    portion.unitsPerDay!.toStringAsFixed(1),
                    portion.unitLabel!,
                  ),
                  style: DSTextStyles.bodyMd,
                ),
              ],
            ],
            const SizedBox(height: DSDimens.sizeXs),
            Text(
              l10n.productDetailPortionDisclaimer,
              style: DSTextStyles.caption.copyWith(color: DSColors.inkTertiary),
            ),
          ],
        ],
      ),
    );
  }
}
