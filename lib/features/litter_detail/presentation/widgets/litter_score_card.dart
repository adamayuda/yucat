import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';
import 'package:yucat/features/product_detail/presentation/utils/verdict_headline.dart';
import 'package:yucat/features/product_detail/presentation/widgets/analysis_chip_row.dart';
import 'package:yucat/features/product_detail/presentation/widgets/ring_score.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';

/// The universal quality verdict.
///
/// The score here is the same for every user — breed, weight and activity do
/// not change what makes a litter good. Anything cat-specific lives in
/// `LitterCatNotesCard` as flags, never as a different number.
class LitterScoreCard extends StatelessWidget {
  final LitterDisplayModel litter;

  const LitterScoreCard({super.key, required this.litter});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final noData = litter.dataUnavailable;
    // Score 0 is the backend's "no data" sentinel — show the neutral headline
    // and body rather than a red "Best to skip this one" verdict.
    final headline = noData
        ? l10n.productDetailNoDataHeadline
        : verdictHeadlineFor(litter.ratingText, l10n);
    final body =
        noData ? l10n.litterDetailNoDataBody : litter.displayDescription;

    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.litterDetailScoreLabel,
                      style: DSTextStyles.caption.copyWith(
                        color: DSColors.inkSecondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: DSDimens.sizeXxs),
                    Text(headline, style: DSTextStyles.displayLg),
                  ],
                ),
              ),
              if (!noData) ...[
                const SizedBox(width: DSDimens.sizeS),
                RingScore(
                  score: litter.score,
                  maxScore: litter.maxScore,
                  ratingColor: litter.ratingColor,
                  size: 64,
                ),
              ],
            ],
          ),
          if (body.isNotEmpty) ...[
            const SizedBox(height: DSDimens.sizeS),
            Text(body, style: DSTextStyles.bodyMd),
          ],
          if (!noData &&
              (litter.displayPros.isNotEmpty ||
                  litter.displayCons.isNotEmpty)) ...[
            const SizedBox(height: DSDimens.sizeS),
            AnalysisChipRow(
              pros: litter.displayPros,
              cons: litter.displayCons,
            ),
          ],
        ],
      ),
    );
  }
}
