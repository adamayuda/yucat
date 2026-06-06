import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';

/// Hydration-themed interstitial for the cat-create wizard (step 5).
///
/// Renders a full-bleed row of glasses — filled on the left, a tall center
/// glass being poured into (stream + droplets rise above the row), empty on the
/// right — over the screen's blue→light gradient (painted by the host
/// [WizardStepShell] via its `backgroundGradient`). Mirrors the design
/// reference "BitePal iOS Taking eating habits quiz 9".
class WaterIntakeFactStep extends StatelessWidget {
  const WaterIntakeFactStep({super.key});

  /// Body height of the short glasses; the pour glass scales to match its cup.
  /// Kept modest so the band + headline + body comfortably fit the step height
  /// (the pour glass renders ~2.8× taller, so this drives the whole band).
  static const double _glassHeight = 100;

  /// glass-pouring.svg is 101×305; ~108px of that (the cup) sits at the bottom,
  /// so render it at the natural ratio to keep cups aligned across the row.
  static const double _pourHeight = _glassHeight * (305 / 108);

  static const String _headline =
      "Hydration protects your cat's kidneys and urinary health";
  static const String _highlight = 'kidneys and urinary health';
  static const String _body =
      'Moisture-rich food lowers the risk of urinary and kidney issues — we '
      'weigh hydration into every assessment.';

  @override
  Widget build(BuildContext context) {
    final parts = _headline.split(_highlight);
    final hasHighlight = _highlight.isNotEmpty && parts.length == 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(flex: 1),
        // Full-bleed glasses band — overflows the shell's horizontal padding so
        // the outer glasses clip at the true screen edges. The SizedBox bounds
        // the band height (the OverflowBox would otherwise try to fill the
        // Column's unbounded vertical space and fail layout); the OverflowBox
        // then lets the row paint wider than the screen.
        SizedBox(
          height: _pourHeight,
          child: OverflowBox(
            maxWidth: double.infinity,
            alignment: Alignment.center,
            child: Row(
              // Size to the glasses, not the unbounded width the OverflowBox
              // grants — a default (max) Row would demand an infinite width.
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _glass('assets/images/glass-full.svg'),
                _glass('assets/images/glass-full.svg'),
                SvgPicture.asset(
                  'assets/images/glass-pouring.svg',
                  height: _pourHeight,
                ),
                _glass('assets/images/glass-empty.svg'),
                _glass('assets/images/glass-empty.svg'),
              ],
            ),
          ),
        ),
        const SizedBox(height: DSDimens.size3xl),
        // The glasses band above is full-bleed; the text insets itself since the
        // shell no longer pads step content.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
          child: hasHighlight
              ? Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: parts[0]),
                      TextSpan(
                        text: _highlight,
                        style: const TextStyle(color: DSColors.accentInfo),
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
          padding: const EdgeInsets.symmetric(horizontal: DSDimens.size3xl),
          child: Text(
            _body,
            textAlign: TextAlign.center,
            style: DSTextStyles.bodyLg.copyWith(color: DSColors.inkSecondary),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }

  Widget _glass(String asset) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeXxs),
        child: SvgPicture.asset(asset, height: _glassHeight),
      );
}
