import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/mascot_illustration.dart';

/// Shared empty/error placeholder. Centered cat-mascot illustration + optional
/// headline + body line + optional pill CTA. Use named constructors
/// `DSStateView.error()` and `DSStateView.empty()` for default mascots and
/// messaging. The illustration is a [MascotIllustration] (cat SVG on a tinted
/// halo) — never a raster GIF.
class DSStateView extends StatelessWidget {
  /// Full cat-figure SVG, e.g. `assets/images/cat-thinking.svg`.
  final String mascotAsset;

  /// Halo color behind the mascot — pick a tint that matches the state's mood.
  final Color tint;
  final String? headline;
  final String body;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;
  final double illustrationSize;

  const DSStateView({
    super.key,
    required this.mascotAsset,
    required this.body,
    this.tint = DSColors.tintLavender,
    this.headline,
    this.ctaLabel,
    this.onCtaPressed,
    this.illustrationSize = 200,
  });

  /// Default error layout: thinking cat on a coral halo + body + Try-again CTA.
  const DSStateView.error({
    super.key,
    required this.body,
    this.headline,
    this.ctaLabel = 'Try again',
    this.onCtaPressed,
    this.illustrationSize = 180,
  })  : mascotAsset = 'assets/images/cat-thinking.svg',
        tint = DSColors.tintCoral;

  /// Default empty layout: requires a mascot, tint, body, and optional CTA.
  const DSStateView.empty({
    super.key,
    required this.mascotAsset,
    required this.body,
    this.tint = DSColors.tintLavender,
    this.headline,
    this.ctaLabel,
    this.onCtaPressed,
    this.illustrationSize = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MascotIllustration(
              mascotAsset: mascotAsset,
              tint: tint,
              size: illustrationSize,
            ),
            if (headline != null) ...[
              const SizedBox(height: DSDimens.sizeS),
              Text(
                headline!,
                textAlign: TextAlign.center,
                style: DSTextStyles.displayLg,
              ),
            ],
            const SizedBox(height: DSDimens.sizeS),
            Text(
              body,
              textAlign: TextAlign.center,
              style: DSTextStyles.bodyLg.copyWith(
                color: DSColors.inkSecondary,
              ),
            ),
            if (ctaLabel != null && onCtaPressed != null) ...[
              const SizedBox(height: DSDimens.sizeL),
              DSPillButton(
                label: ctaLabel!,
                onPressed: onCtaPressed,
                showChevron: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
