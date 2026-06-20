import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// Hydration-themed interstitial for the cat-create wizard (step 5).
///
/// Renders a depth-layered scatter of cat bowls (`water-bowl.svg`) over the
/// screen's blue→light gradient (painted by the host [WizardStepShell] via its
/// `backgroundGradient`): a faded back pair high and outward, a full mid pair,
/// and a large front-center bowl being poured into by a water stream
/// (`water-pour.svg`, stream column + droplets). Bowls are painted back-to-front
/// so the front rim covers the stream's lower end for the "pouring in" read.
class WaterIntakeFactStep extends StatelessWidget {
  const WaterIntakeFactStep({super.key});

  /// Height of the bowl scene band; drives the stream length and overall fit so
  /// the headline + body comfortably follow within the step height.
  static const double _bandHeight = 270;

  /// Bowl widths by depth — closer bowls render larger (foreground bias). The
  /// front bowl is the hero (drives the stream length too); the four others are
  /// noticeably smaller so they read as background.
  static const double _frontBowlWidth = 135;
  static const double _midBowlWidth = 100;
  static const double _backBowlWidth = 100;

  /// `water-bowl.svg` intrinsic aspect (103 / 136) and the vertical fraction of
  /// the bowl at which its water ellipse sits (cy 24.5 / height 103).
  static const double _bowlAspect = 103 / 136;
  static const double _bowlWaterFraction = 24.5 / 103;

  /// Front bowl's rendered height, and the stream length: from the top edge down
  /// to the front bowl's water surface (plus a few px so it plunges into the
  /// water rather than hovering above the rim). The stream is painted *over* the
  /// front bowl so it lands in the visible water ellipse — the "pouring in" read.
  static const double _frontBowlHeight = _frontBowlWidth * _bowlAspect;
  static const double _streamHeight =
      _bandHeight - _frontBowlHeight * (1 - _bowlWaterFraction) + 8;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final headline = l10n.waterFactHeadline;
    final highlight = l10n.waterFactHighlight;
    final body = l10n.waterFactBody;
    final parts = headline.split(highlight);
    final hasHighlight = highlight.isNotEmpty && parts.length == 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(flex: 1),
        // Full-bleed bowl scene — the shell pads neither side, so the Stack
        // spans the screen width and the bowls scatter across it.
        SizedBox(
          width: double.infinity,
          height: _bandHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Back pair: faded + high + outward (the "far" depth).
              _bowl(
                width: _backBowlWidth,
                opacity: 0.4,
                alignment: const Alignment(-0.95, -.5),
              ),
              _bowl(
                width: _backBowlWidth,
                opacity: 0.4,
                alignment: const Alignment(0.95, -.5),
              ),
              // Mid pair: near-full, between the back pair and the front bowl.
              _bowl(
                width: _midBowlWidth,
                opacity: 0.82,
                alignment: const Alignment(-0.75, 0.35),
              ),
              _bowl(
                width: _midBowlWidth,
                opacity: 0.82,
                alignment: const Alignment(0.75, 0.35),
              ),
              // Front-center bowl.
              _bowl(
                width: _frontBowlWidth,
                opacity: 1,
                alignment: Alignment.bottomCenter,
              ),
              // Water stream from the top edge — painted *over* the front bowl so
              // it lands in the visible water ellipse (the "pouring in" read).
              Align(
                alignment: Alignment.topCenter,
                child: SvgPicture.asset(
                  'assets/images/water-pour.svg',
                  height: _streamHeight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DSDimens.size3xl),
        // The bowl scene above is full-bleed; the text insets itself since the
        // shell no longer pads step content.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
          child: hasHighlight
              ? Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: parts[0]),
                      TextSpan(
                        text: highlight,
                        style: const TextStyle(color: DSColors.accentInfo),
                      ),
                      TextSpan(text: parts[1]),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: DSTextStyles.displayLg,
                )
              : Text(
                  headline,
                  textAlign: TextAlign.center,
                  style: DSTextStyles.displayLg,
                ),
        ),
        const SizedBox(height: DSDimens.sizeS),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSDimens.size3xl),
          child: Text(
            body,
            textAlign: TextAlign.center,
            style: DSTextStyles.bodyLg.copyWith(color: DSColors.inkSecondary),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }

  Widget _bowl({
    required double width,
    required double opacity,
    required Alignment alignment,
  }) => Align(
    alignment: alignment,
    child: Opacity(
      opacity: opacity,
      child: SvgPicture.asset('assets/images/water-bowl.svg', width: width),
    ),
  );
}
