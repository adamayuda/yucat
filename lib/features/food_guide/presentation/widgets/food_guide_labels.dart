import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/food_guide/domain/entities/food_guide_entity.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// Localized copy for [FoodSafety]. Kept beside the pill so the row, the pill
/// and the detail screen can't drift apart.
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
/// the word carry it.
///
/// ⚠️ The caution state is **amber** here (`accentWarning` on `tintSand`) while
/// the recipe pill's caution stays coral. That is deliberate, not drift: amber
/// reads as a severity between safe and unsafe, which is what a feeding
/// guideline needs, whereas coral is an emphasis colour elsewhere in the app.
class FoodSafetyPill extends StatelessWidget {
  final FoodSafety safety;

  const FoodSafetyPill({super.key, required this.safety});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (background, foreground) = switch (safety) {
      FoodSafety.safe => (DSColors.accentSuccessSoft, DSColors.accentSuccess),
      FoodSafety.caution => (DSColors.tintSand, DSColors.accentWarning),
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

/// The stand-in when a category has no photo, or its photo fails to load.
///
/// Shared by the list row's thumbnail and the detail hero so the two can't show
/// different fallbacks for the same entry. Deliberately not
/// `HatchedPlaceholder`: that paints a "no image" tag, which is right for a
/// product whose photo lookup failed and wrong for an entry that simply has
/// none.
class FoodGuideEmoji extends StatelessWidget {
  final String emoji;
  final double size;

  const FoodGuideEmoji({super.key, required this.emoji, required this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: emoji.isEmpty
          ? Icon(
              Icons.restaurant_rounded,
              color: DSColors.inkTertiary,
              size: size * 0.6,
            )
          : ExcludeSemantics(
              child: Text(emoji, style: TextStyle(fontSize: size)),
            ),
    );
  }
}
