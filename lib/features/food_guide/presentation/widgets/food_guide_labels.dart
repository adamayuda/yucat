import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/food_guide/domain/entities/food_guide_entity.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// Localized copy for [FoodSafety]. Kept beside the pill so the tile, the pill
/// and any future list can't drift apart.
extension FoodSafetyL10n on FoodSafety {
  String label(AppLocalizations l10n) => switch (this) {
        FoodSafety.safe => l10n.foodGuideSafetySafe,
        FoodSafety.caution => l10n.foodGuideSafetyCaution,
        FoodSafety.unsafe => l10n.foodGuideSafetyUnsafe,
      };
}

/// Whether a cat can eat this food, as a soft pill.
///
/// Deliberately icon-free, unlike `RecipeCompatibilityPill` — the colour and
/// the word carry it, and the detail screen already leads with the name. The
/// colour mapping is the same one, so the two read as siblings.
class FoodSafetyPill extends StatelessWidget {
  final FoodSafety safety;

  const FoodSafetyPill({super.key, required this.safety});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (background, foreground) = switch (safety) {
      FoodSafety.safe => (DSColors.accentSuccessSoft, DSColors.accentSuccess),
      FoodSafety.caution => (DSColors.coralSurface, DSColors.coralAccent),
      FoodSafety.unsafe => (DSColors.tintCoral, DSColors.accentDanger),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeS,
        vertical: DSDimens.sizeXxs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(DSRadii.pill),
      ),
      child: Text(
        safety.label(l10n),
        style: DSTextStyles.label.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
