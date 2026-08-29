import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/onboarding_floating_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

/// Phase 2 — sells the recipes + articles catalogue before the survey starts.
/// Replaced the "How did you hear about us?" attribution screen, which is
/// parked (not deleted) in `attribution_screen.dart`.
class RecipesArticlesScreen extends StatelessWidget {
  /// Intrinsic ratio of `onboarding-recipes.png` (335×354).
  static const double _collageAspect = 335 / 354;

  final VoidCallback onNext;

  const RecipesArticlesScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return OnboardingScaffold(
      background: DSColors.tintCloud,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          // The collage is an authored composition carrying its own rounded
          // corners and lavender ground, so `contain` — `cover` would crop
          // the corners off on wide screens.
          //
          // AspectRatio pins the box to the artwork's own ratio so the fade
          // below hugs the image rather than the letterboxed slack `contain`
          // would otherwise leave above and below it.
          Expanded(
            flex: 12,
            child: Center(
              child: AspectRatio(
                aspectRatio: _collageAspect,
                child: ShaderMask(
                  // Softens the hard edges where the collage's photos are cut
                  // off, dissolving them into the page instead.
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black,
                      Colors.black,
                      Colors.transparent,
                    ],
                    stops: [0, 0.14, 0.86, 1],
                  ).createShader(bounds),
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    'assets/images/onboarding-recipes.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
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
