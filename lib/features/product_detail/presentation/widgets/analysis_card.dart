import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/utils/verdict_headline.dart';
import 'package:yucat/features/product_detail/presentation/widgets/analysis_chip_row.dart';
import 'package:yucat/features/product_detail/presentation/widgets/ring_score.dart';
import 'package:yucat/presentation/components/ds_card.dart';

class AnalysisCard extends StatelessWidget {
  final ProductDisplayModel product;
  final String? description;

  const AnalysisCard({super.key, required this.product, this.description});

  @override
  Widget build(BuildContext context) {
    final headline = verdictHeadlineFor(product.ratingText);
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
                      'OVERALL ANALYSIS',
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
              const SizedBox(width: DSDimens.sizeS),
              RingScore(
                score: product.score,
                maxScore: product.maxScore,
                ratingColor: product.ratingColor,
                size: 64,
              ),
            ],
          ),
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: DSDimens.sizeS),
            Text(description!, style: DSTextStyles.bodyMd),
          ],
          if (product.pros.isNotEmpty || product.cons.isNotEmpty) ...[
            const SizedBox(height: DSDimens.sizeS),
            AnalysisChipRow(pros: product.pros, cons: product.cons),
          ],
        ],
      ),
    );
  }
}
