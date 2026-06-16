import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/presentation/utils/cat_diet_recommendations.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';

/// A titled card listing personalized dietary tips for a cat. Used on the cat
/// detail page (full list) and the home dashboard (top few tips).
class DietaryRecommendationsCard extends StatelessWidget {
  final String title;
  final List<DietRecommendation> recommendations;

  /// Tap target for the whole card (e.g. open cat detail from the dashboard).
  final VoidCallback? onTap;

  /// Whether to show the "consult your vet" footnote (hidden in compact spots).
  final bool showDisclaimer;

  const DietaryRecommendationsCard({
    super.key,
    required this.title,
    required this.recommendations,
    this.onTap,
    this.showDisclaimer = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DSCard(
      onTap: onTap,
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: DSTextStyles.titleMd),
          const SizedBox(height: DSDimens.sizeS),
          for (var i = 0; i < recommendations.length; i++) ...[
            if (i > 0) const SizedBox(height: DSDimens.sizeM),
            DietRecommendationRow(recommendation: recommendations[i]),
          ],
          if (showDisclaimer) ...[
            const SizedBox(height: DSDimens.sizeS),
            Text(
              l10n.dietTipsDisclaimer,
              style: DSTextStyles.caption.copyWith(color: DSColors.inkTertiary),
            ),
          ],
        ],
      ),
    );
  }
}

/// A single dietary tip: a direction-tinted nutrient icon, bold title, and a
/// short rationale. Modeled on the onboarding/snapshot summary rows.
class DietRecommendationRow extends StatelessWidget {
  final DietRecommendation recommendation;

  const DietRecommendationRow({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final more = recommendation.direction == DietDirection.more;
    final bg = more ? DSColors.tintMint : DSColors.tintSky;
    final fg = more ? DSColors.accentSuccess : DSColors.accentInfo;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(DSRadii.sm),
          ),
          child: Icon(_iconFor(recommendation.nutrient), color: fg, size: 22),
        ),
        const SizedBox(width: DSDimens.sizeS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recommendation.title,
                style: DSTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: DSColors.inkPrimary,
                ),
              ),
              const SizedBox(height: DSDimens.sizeXxxxs),
              Text(
                recommendation.why,
                style: DSTextStyles.bodyMd.copyWith(
                  color: DSColors.inkSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _iconFor(DietNutrient nutrient) {
    switch (nutrient) {
      case DietNutrient.protein:
        return Icons.egg_alt_rounded;
      case DietNutrient.fat:
        return Icons.opacity_rounded;
      case DietNutrient.carbs:
        return Icons.grain_rounded;
      case DietNutrient.fiber:
        return Icons.grass_rounded;
      case DietNutrient.moisture:
        return Icons.water_drop_outlined;
      case DietNutrient.omega3:
        return Icons.set_meal_rounded;
      case DietNutrient.phosphorus:
        return Icons.science_rounded;
      case DietNutrient.calories:
        return Icons.local_fire_department_rounded;
      case DietNutrient.water:
        return Icons.water_drop_rounded;
      case DietNutrient.taurine:
        return Icons.favorite_rounded;
      case DietNutrient.sodium:
        return Icons.science_outlined;
      case DietNutrient.novelProtein:
        return Icons.restaurant_menu_rounded;
      case DietNutrient.digestibility:
        return Icons.spa_rounded;
    }
  }
}
