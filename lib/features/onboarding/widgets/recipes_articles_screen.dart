import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/onboarding/widgets/recipes_marquee.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/onboarding_floating_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

/// Phase 2 — sells the recipes + articles catalogue before the survey starts.
/// Replaced the "How did you hear about us?" attribution screen, which is
/// parked (not deleted) in `attribution_screen.dart`.
class RecipesArticlesScreen extends StatelessWidget {
  final VoidCallback onNext;

  /// Whether this is the currently-visible phase. Forwarded to the marquee,
  /// which pauses when it isn't — see `RecipesMarquee`.
  final bool active;

  const RecipesArticlesScreen({
    super.key,
    required this.onNext,
    this.active = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return OnboardingScaffold(
      background: DSColors.tintCloud,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          Expanded(
            flex: 12,
            child: ShaderMask(
              // Dissolves the tiles into the page at the boundaries instead of
              // cutting them on a hard line — more load-bearing now that the
              // collage scrolls and tiles genuinely straddle the edge.
              //
              // The ramp is quadratic (alpha ≈ t²), not linear, and spans 22%
              // rather than 14%. A linear 14% band reached alpha 0.71 by a
              // tenth of the height, which left a half-visible photo reading as
              // a pale rounded rectangle against `tintCloud` — three of those
              // side by side looked like a line across the top of the collage.
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00000000),
                  Color(0x10000000),
                  Color(0x40000000),
                  Color(0x90000000),
                  Color(0xFF000000),
                  Color(0xFF000000),
                  Color(0x90000000),
                  Color(0x40000000),
                  Color(0x10000000),
                  Color(0x00000000),
                ],
                stops: [
                  0, 0.055, 0.11, 0.165, 0.22,
                  0.78, 0.835, 0.89, 0.945, 1,
                ],
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: RecipesMarquee(active: active),
            ),
          ),
          const SizedBox(height: DSDimens.size3xl),
          Text(
            l10n.onboardingRecipesTitle,
            textAlign: TextAlign.center,
            style: DSTextStyles.displayLg,
          ),
          const SizedBox(height: DSDimens.sizeS),
          Text(
            l10n.onboardingRecipesSubtitle,
            textAlign: TextAlign.center,
            style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkSecondary),
          ),
          const Spacer(flex: 2),
          OnboardingFloatingButton(label: l10n.commonNext, onPressed: onNext),
        ],
      ),
    );
  }
}
