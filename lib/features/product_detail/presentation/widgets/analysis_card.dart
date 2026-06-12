import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/utils/verdict_headline.dart';
import 'package:yucat/features/product_detail/presentation/widgets/analysis_chip_row.dart';
import 'package:yucat/features/product_detail/presentation/widgets/ring_score.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';

class AnalysisCard extends StatelessWidget {
  final ProductDisplayModel product;
  final String? description;

  const AnalysisCard({super.key, required this.product, this.description});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final noData = product.dataUnavailable;
    // When no guaranteed analysis was found, show a neutral "no info yet"
    // headline and a localized body — never the red score-0 "Poor" verdict or
    // the jargony backend description.
    final headline =
        noData ? l10n.productDetailNoDataHeadline : verdictHeadlineFor(product.ratingText, l10n);
    final body = noData ? l10n.productDetailNoDataBody : description;
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
                      l10n.productDetailOverallAnalysis,
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
              // Hide the score ring entirely when there's no data to score.
              if (!noData) ...[
                const SizedBox(width: DSDimens.sizeS),
                RingScore(
                  score: product.score,
                  maxScore: product.maxScore,
                  ratingColor: product.ratingColor,
                  size: 64,
                ),
              ],
            ],
          ),
          if (body != null && body.isNotEmpty) ...[
            const SizedBox(height: DSDimens.sizeS),
            Text(body, style: DSTextStyles.bodyMd),
          ],
          if (!noData && (product.pros.isNotEmpty || product.cons.isNotEmpty)) ...[
            const SizedBox(height: DSDimens.sizeS),
            AnalysisChipRow(pros: product.pros, cons: product.cons),
          ],
        ],
      ),
    );
  }
}
