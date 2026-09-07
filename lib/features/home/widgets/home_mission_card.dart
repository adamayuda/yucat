import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// Closing note at the foot of Home — what YuCat is for, in two sentences.
///
/// Deliberately not a `DSCard`: this is a quiet sign-off, not a surface the
/// user acts on, so it sits on a flat `tintMist` panel with no shadow and no
/// tap target. Pure chrome — the copy lives in the ARBs, not Firestore.
class HomeMissionCard extends StatelessWidget {
  const HomeMissionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(DSDimens.sizeL),
      decoration: BoxDecoration(
        color: DSColors.tintMist,
        borderRadius: BorderRadius.circular(DSRadii.xl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.homeMissionTitle, style: DSTextStyles.headlineMd),
                const SizedBox(height: DSDimens.sizeXs),
                Text(
                  l10n.homeMissionBody,
                  style: DSTextStyles.bodyLg.copyWith(
                    color: DSColors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: DSDimens.sizeS),
          // The idle mascot — a 3 s loop that carries the brand's tone better
          // than an abstract glyph. It replaced the static `cat-thumb.svg`
          // (YUC-25), which is still used by the cat-create coat step.
          //
          // `width: 80` is unchanged from the SVG on purpose: the two share an
          // aspect ratio to within 1 % (257×289 vs 300×335), so the swap moves
          // the card's height by well under a pixel.
          //
          // ⚠️ `frameRate: FrameRate.composition` is load-bearing, not a
          // flourish. This loops forever at the foot of a `ListView`, which
          // keeps it ticking inside the cache extent even when it's scrolled
          // off — and the default drives repaints at the device refresh rate,
          // so a 120 Hz ProMotion screen would repaint 4× per authored frame
          // for no visible gain. `composition` pins it to the file's own
          // 30 fps and follows the asset if it's ever re-exported.
          ExcludeSemantics(
            child: Lottie.asset(
              'assets/images/cat-idle.json',
              width: 80,
              frameRate: FrameRate.composition,
            ),
          ),
        ],
      ),
    );
  }
}
