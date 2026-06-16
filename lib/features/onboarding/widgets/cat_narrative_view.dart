import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/domain/entities/cat_narrative.dart';
import 'package:yucat/features/cat/presentation/utils/cat_diet_recommendations.dart';
import 'package:yucat/features/cat/presentation/widgets/dietary_recommendations_card.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// Renders a pre-resolved personalized narrative for the result screen: the
/// Haiku prose (or a local fallback), the "What to focus on" tip cards, and the
/// forward-looking "~2 weeks" outlook. The generation already happened on the
/// analyze screen — this widget is purely presentational (no fetch / no loading).
class CatNarrativeView extends StatelessWidget {
  final CatEntity entity;

  /// The generated narrative, or null to render the local fallback.
  final CatNarrative? result;

  const CatNarrativeView({
    super.key,
    required this.entity,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prose =
        result?.narrative ?? l10n.onboardingNarrativeFallback(entity.name);
    final outlook =
        result?.outlook ?? l10n.onboardingNarrativeOutlookFallback(entity.name);
    final focusTips = recommendDiet(entity, l10n).take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DSDimens.sizeS),
          decoration: BoxDecoration(
            color: DSColors.tintLavender,
            borderRadius: BorderRadius.circular(DSRadii.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: DSColors.accentInfo,
                  ),
                  const SizedBox(width: DSDimens.sizeXxs),
                  Text(
                    l10n.onboardingNarrativeTitle,
                    style: DSTextStyles.caption.copyWith(
                      color: DSColors.inkTertiary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DSDimens.sizeXs),
              Text(
                prose,
                style: DSTextStyles.bodyLg.copyWith(color: DSColors.inkPrimary),
              ),
              if (focusTips.isNotEmpty) ...[
                const SizedBox(height: DSDimens.sizeL),
                Text(
                  l10n.onboardingNarrativeFocusTitle(entity.name),
                  style: DSTextStyles.caption.copyWith(
                    color: DSColors.inkTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: DSDimens.sizeS),
                for (var i = 0; i < focusTips.length; i++) ...[
                  if (i > 0) const SizedBox(height: DSDimens.sizeM),
                  DietRecommendationRow(recommendation: focusTips[i]),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: DSDimens.sizeS),
        _OutlookCallout(
          title: l10n.onboardingNarrativeOutlookTitle,
          body: outlook,
        ),
      ],
    );
  }
}

/// The forward-looking "✨ In about 2 weeks" highlight under the narrative.
class _OutlookCallout extends StatelessWidget {
  final String title;
  final String body;

  const _OutlookCallout({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSDimens.sizeS),
      decoration: BoxDecoration(
        color: DSColors.accentSuccessSoft,
        borderRadius: BorderRadius.circular(DSRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: DSColors.accentSuccess,
              ),
              const SizedBox(width: DSDimens.sizeXxs),
              Text(
                title,
                style: DSTextStyles.caption.copyWith(
                  color: DSColors.accentSuccess,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSDimens.sizeXxs),
          Text(
            body,
            style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkPrimary),
          ),
        ],
      ),
    );
  }
}
