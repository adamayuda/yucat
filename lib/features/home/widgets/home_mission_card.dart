import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          // The winking cat the removed scan hero card used — the mascot has no
          // other home on Home now, and it carries the brand's tone better than
          // an abstract glyph. Rendered at its own colours: no ColorFilter.
          ExcludeSemantics(
            child: SvgPicture.asset(
              'assets/images/cat-thumb.svg',
              width: 80,
            ),
          ),
        ],
      ),
    );
  }
}
