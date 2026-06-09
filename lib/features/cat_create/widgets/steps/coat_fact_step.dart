import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';

/// Coat-health interstitial for the cat-create wizard (step 8).
///
/// A warm "sunburst" motivational beat — cream rays + soft glow ([bg-light]),
/// a thumbs-up mascot ([cat-thumb]) and scattered stars — mirroring the design
/// reference "BitePal iOS Setting up goals 6". The backdrop lives inside the
/// step (not the host shell) so it slides in with the content on transition.
class CoatFactStep extends StatelessWidget {
  const CoatFactStep({super.key});

  static const String _headline = 'Long-haired cats need\nmore omega-3';
  static const String _highlight = 'more omega-3';
  static const String _body =
      'Omega-3 keeps their coat glossy and skin healthy.';

  @override
  Widget build(BuildContext context) {
    final parts = _headline.split(_highlight);
    final hasHighlight = _highlight.isNotEmpty && parts.length == 2;

    // The warm sunburst backdrop (bg-light.svg) is painted full-screen by the
    // host WizardStepShell via its `backgroundChild`, so this step only layers
    // the stars + content on top.
    return Stack(
      fit: StackFit.expand,
      children: [
        // Scattered decorative stars around the mascot.
        const _Star(asset: 'star-green.svg', size: 30, top: 192, right: 108),
        const _Star(asset: 'star-red.svg', size: 34, top: 212, right: 40),
        const _Star(asset: 'star-brown.svg', size: 28, top: 268, left: 32),
        const _Star(asset: 'star-blur.svg', size: 44, top: 356, right: 52),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: DSDimens.sizeS),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
              child: hasHighlight
                  ? Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: parts[0]),
                          const TextSpan(
                            text: _highlight,
                            style: TextStyle(color: DSColors.accentSuccess),
                          ),
                          TextSpan(text: parts[1]),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: DSTextStyles.displayLg,
                    )
                  : Text(
                      _headline,
                      textAlign: TextAlign.center,
                      style: DSTextStyles.displayLg,
                    ),
            ),
            const SizedBox(height: DSDimens.sizeS),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
              child: Text(
                _body,
                textAlign: TextAlign.center,
                style: DSTextStyles.bodyLg.copyWith(
                  color: DSColors.inkSecondary,
                ),
              ),
            ),
            // Fixed gap (not a flex Spacer) so the cat is anchored from the
            // top and doesn't drift down when the next (floating-CTA) step
            // grows the content area mid-transition. The trailing Spacer
            // absorbs that height change instead.
            const SizedBox(height: DSDimens.size3xl),
            SvgPicture.asset(
              'assets/images/cat-thumb.svg',
              height: 280,
            ),
            const Spacer(),
          ],
        ),
      ],
    );
  }
}

/// Decorative star pinned around the mascot (fixed, behind the content).
class _Star extends StatelessWidget {
  final String asset;
  final double size;
  final double? top;
  final double? left;
  final double? right;

  const _Star({
    required this.asset,
    required this.size,
    this.top,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: ExcludeSemantics(
        child: SvgPicture.asset('assets/images/$asset', width: size),
      ),
    );
  }
}
