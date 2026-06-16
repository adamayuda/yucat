import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_route/auto_route.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_narrative.dart';
import 'package:yucat/features/cat_create/presentation/models/cat_summary.dart';
import 'package:yucat/features/onboarding/widgets/cat_narrative_view.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

/// The "reveal" after the analyze beat: the personalized narrative + focus tips
/// + "~2 weeks" outlook, plus the profile recap. Its CTA continues to the brand
/// step (which finalizes onboarding → paywall) via [onStart]. The narrative is
/// already resolved (on the analyze screen) and passed in — null renders the
/// local fallback. Product picks are intentionally NOT shown here — they're the
/// locked teaser on the brand step.
class ResultScreen extends StatelessWidget {
  final void Function(BuildContext context) onStart;
  final CatSummary summary;
  final CatNarrative? narrative;

  const ResultScreen({
    super.key,
    required this.onStart,
    required this.summary,
    required this.narrative,
  });

  static const _bg = DSColors.tintCloud;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: DSGradients.onboardingSuccess,
        ),
        child: Stack(
          children: [
            // Scrolling content — fades out under the floating CTA.
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    DSDimens.sizeXxs,
                    DSDimens.sizeL,
                    DSDimens.sizeXxs,
                    150,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        l10n.onboardingResultTitle(summary.name.trim()),
                        textAlign: TextAlign.center,
                        style: DSTextStyles.displayHero,
                      ),
                      // Mascot peeking out from behind the summary card; pulled
                      // up with a negative offset to tighten the gap under the
                      // title.
                      Transform.translate(
                        offset: const Offset(0, -40),
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            SvgPicture.asset(
                              'assets/images/cat-laught.svg',
                              height: 300,
                            ),
                            const Positioned(
                              top: 10,
                              right: 24,
                              child: _Sparkle(size: 44),
                            ),
                            const Positioned(
                              top: 96,
                              left: 18,
                              child: _Sparkle(size: 28),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 224),
                              child: _SummaryCard(
                                summary: summary,
                                narrative: narrative,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Fade gradient behind the floating CTA.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 140,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_bg.withValues(alpha: 0), _bg],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DSDimens.sizeL,
                    DSDimens.sizeS,
                    DSDimens.sizeL,
                    DSDimens.size3xl,
                  ),
                  child: Center(
                    heightFactor: 1,
                    child: DSPillButton(
                      label: l10n.onboardingResultContinue,
                      onPressed: () => context.router.push(
                        CurrentFoodRoute(summary: summary, onStart: onStart),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final CatSummary summary;
  final CatNarrative? narrative;

  const _SummaryCard({required this.summary, required this.narrative});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notSet = l10n.onboardingSuccessNotSet;
    final healthValue = summary.healthLabels.isEmpty
        ? l10n.onboardingSuccessNone
        : summary.healthLabels.join(', ');

    // Every attribute is always shown; anything the user skipped reads
    // "Not set" (muted) so the profile recap stays complete.
    final rows = <Widget>[
      _SummaryRow(
        iconAsset: 'Cake.svg',
        label: l10n.onboardingSuccessRowAge,
        value: summary.ageLabel ?? notSet,
        muted: summary.ageLabel == null,
      ),
      _SummaryRow(
        iconAsset: 'Activity.svg',
        label: l10n.onboardingSuccessRowActivity,
        value: summary.activityLabel ?? notSet,
        muted: summary.activityLabel == null,
      ),
      _SummaryRow(
        iconAsset: 'Body condition.svg',
        label: l10n.onboardingSuccessRowBodyCondition,
        value: summary.bodyConditionLabel ?? notSet,
        muted: summary.bodyConditionLabel == null,
      ),
      _SummaryRow(
        iconAsset: 'Coat.svg',
        label: l10n.onboardingSuccessRowCoat,
        value: summary.coatLabel ?? notSet,
        muted: summary.coatLabel == null,
      ),
      _SummaryRow(
        iconAsset: 'Neuter status.svg',
        label: l10n.onboardingSuccessRowNeuterStatus,
        value: summary.neuterLabel ?? notSet,
        muted: summary.neuterLabel == null,
      ),
      _SummaryRow(
        iconAsset: 'catwalk.svg',
        label: l10n.onboardingSuccessRowBreed,
        value: summary.breed ?? notSet,
        muted: summary.breed == null,
      ),
      _SummaryRow(
        iconAsset: 'Health.svg',
        label: l10n.onboardingSuccessRowHealthConditions,
        value: healthValue,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeS,
        vertical: DSDimens.sizeL,
      ),
      decoration: BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.xl),
        boxShadow: DSShadows.e1,
      ),
      child: Column(
        children: [
          CatNarrativeView(entity: summary.entity, result: narrative),
          const SizedBox(height: DSDimens.sizeL),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: DSDimens.sizeM),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  /// Colorful attribute icon under `assets/images/` (e.g. `Activity.svg`).
  final String iconAsset;
  final String label;
  final String value;

  /// Renders the value in a muted colour (e.g. for a "Not set" placeholder).
  final bool muted;

  const _SummaryRow({
    required this.iconAsset,
    required this.label,
    required this.value,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: SvgPicture.asset(
              'assets/images/$iconAsset',
              width: 36,
              height: 36,
            ),
          ),
        ),
        const SizedBox(width: DSDimens.sizeS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: DSTextStyles.caption.copyWith(
                  color: DSColors.inkTertiary,
                ),
              ),
              const SizedBox(height: DSDimens.sizeXxxxs),
              Text(
                value,
                style: DSTextStyles.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: muted ? DSColors.inkTertiary : DSColors.inkPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Sparkle extends StatelessWidget {
  final double size;

  const _Sparkle({required this.size});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SvgPicture.asset('assets/images/star-cyan.svg', width: size),
    );
  }
}
