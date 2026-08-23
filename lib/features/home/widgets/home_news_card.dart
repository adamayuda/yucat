import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

/// The daily "good to know" card on Home: a blue eyebrow, a headline, a short
/// body, a square thumbnail and a "Learn more" link.
///
/// Content is a single hardcoded item for now — there is no article store and
/// no destination screen, so the link is deliberately inert.
class HomeNewsCard extends StatelessWidget {
  const HomeNewsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DSDimens.sizeXs,
              DSDimens.sizeXs,
              0,
              0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ExcludeSemantics(
                            child: SvgPicture.asset(
                              'assets/images/star-sharp.svg',
                              width: 13,
                              colorFilter: const ColorFilter.mode(
                                DSColors.accentInfo,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          const SizedBox(width: DSDimens.sizeXxs),
                          Flexible(
                            child: Text(
                              l10n.homeNewsEyebrow.toUpperCase(),
                              style: DSTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: DSColors.accentInfo,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DSDimens.sizeXs),
                      Text(
                        l10n.homeNewsTitle,
                        style: DSTextStyles.headlineMd,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: DSDimens.sizeXxs),
                      Text(
                        l10n.homeNewsBody,
                        style: DSTextStyles.bodyLg.copyWith(
                          color: DSColors.inkSecondary,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DSDimens.sizeS),
                const _NewsThumb(),
              ],
            ),
          ),
          const SizedBox(height: DSDimens.sizeXxs),
          DSTextLink(
            label: l10n.homeNewsLearnMore,
            trailingIcon: Icons.arrow_forward_rounded,
            // TODO(home): point at the article screen once one exists.
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

/// Placeholder for the article photo — an emoji on a tinted square. Swapping
/// in a real image is a one-widget change once articles carry one.
class _NewsThumb extends StatelessWidget {
  const _NewsThumb();

  static const double _size = 88;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: DSColors.tintLavender,
        borderRadius: BorderRadius.circular(DSRadii.lg),
      ),
      alignment: Alignment.center,
      child: const ExcludeSemantics(
        child: Text('🐱', style: TextStyle(fontSize: 40)),
      ),
    );
  }
}
