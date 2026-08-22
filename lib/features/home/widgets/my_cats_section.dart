import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/presentation/utils/cat_diet_recommendations.dart';
import 'package:yucat/features/cat/presentation/widgets/dietary_recommendations_card.dart';
import 'package:yucat/features/cat/presentation/widgets/recommended_products_section.dart';
import 'package:yucat/features/home/widgets/active_cat_snapshot_card.dart';
import 'package:yucat/features/home/widgets/cat_profile_completion_card.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// "My cats" section of the Home dashboard: everything that keys off the
/// active cat. Selection itself lives in `HomeGreetingCard` at the top of the
/// page, so this section only receives the cat that was chosen there.
class MyCatsSection extends StatelessWidget {
  final CatEntity? activeCat;
  final ValueChanged<CatEntity> onCatTap;
  final ValueChanged<CatEntity> onCompleteProfile;

  const MyCatsSection({
    super.key,
    required this.activeCat,
    required this.onCatTap,
    required this.onCompleteProfile,
  });

  @override
  Widget build(BuildContext context) {
    final cat = activeCat;
    // With no cats there is nothing to show — the greeting card's "add" tile
    // is the only entry point.
    if (cat == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header — padded to align with page content.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
          child: Row(
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.homeMyCatsTitle,
                    style: DSTextStyles.displayLg,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DSDimens.sizeS),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
          child: ActiveCatSnapshotCard(
            cat: cat,
            onTap: () => onCatTap(cat),
          ),
        ),
        if (!catProfileCompletion(cat).isComplete)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DSDimens.sizeL,
              DSDimens.sizeS,
              DSDimens.sizeL,
              0,
            ),
            child: CatProfileCompletionCard(
              cat: cat,
              onComplete: () => onCompleteProfile(cat),
            ),
          ),
        _ActiveCatTips(cat: cat, onTap: () => onCatTap(cat)),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            DSDimens.sizeL,
            DSDimens.sizeL,
            DSDimens.sizeL,
            0,
          ),
          child: RecommendedProductsSection(cat: cat),
        ),
      ],
    );
  }
}

/// Top dietary tips for the active cat, shown under its snapshot. Tapping opens
/// the cat's detail page (where the full list lives). Stays in sync with the
/// greeting card's picker since it reads the same `activeCat`.
class _ActiveCatTips extends StatelessWidget {
  final CatEntity cat;
  final VoidCallback onTap;

  const _ActiveCatTips({required this.cat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tips = recommendDiet(cat, l10n).take(3).toList();
    if (tips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSDimens.sizeL,
        DSDimens.sizeS,
        DSDimens.sizeL,
        0,
      ),
      child: DietaryRecommendationsCard(
        title: l10n.homeCatTipsTitle(cat.name),
        recommendations: tips,
        showDisclaimer: false,
        onTap: onTap,
      ),
    );
  }
}
