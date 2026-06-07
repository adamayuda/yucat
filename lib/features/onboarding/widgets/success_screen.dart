import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat_create/presentation/models/cat_summary.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

class SuccessScreen extends StatelessWidget {
  final VoidCallback onStart;

  /// Structured recap of the cat the user just created.
  final CatSummary? summary;

  const SuccessScreen({
    super.key,
    required this.onStart,
    this.summary,
  });

  static const _bg = DSColors.tintCloud;

  @override
  Widget build(BuildContext context) {
    final name = summary?.name.trim();
    final hasName = name != null && name.isNotEmpty;

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
                    DSDimens.sizeL,
                    DSDimens.sizeL,
                    DSDimens.sizeL,
                    150,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        hasName ? '$name is\nall set!' : "You're all\nset!",
                        textAlign: TextAlign.center,
                        style: DSTextStyles.displayHero,
                      ),
                      const SizedBox(height: DSDimens.sizeL),
                      // Mascot peeking out from behind the summary card.
                      Stack(
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
                          if (summary != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 224),
                              child: _SummaryCard(summary: summary!),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Fade gradient behind the floating CTA (same effect as the wizard's
            // floating-next steps, e.g. breed_step).
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSDimens.sizeL,
                    vertical: DSDimens.sizeS,
                  ),
                  // Center keeps the button content-sized (loose constraints);
                  // a bare Positioned child gets tight full-width constraints
                  // and the pill would stretch edge-to-edge.
                  child: Center(
                    heightFactor: 1,
                    child: DSPillButton(
                      label: 'Start scanning',
                      onPressed: onStart,
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

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    const notSet = 'Not set';
    final healthValue = summary.healthLabels.isEmpty
        ? 'None'
        : summary.healthLabels.join(', ');

    // Every attribute is always shown; anything the user skipped reads
    // "Not set" (muted) so the profile recap stays complete.
    final rows = <Widget>[
      _SummaryRow(
        icon: Icons.cake_rounded,
        tint: DSColors.tintMint,
        label: 'Age',
        value: summary.ageLabel ?? notSet,
        muted: summary.ageLabel == null,
      ),
      _SummaryRow(
        icon: Icons.bolt_rounded,
        tint: DSColors.tintSand,
        label: 'Activity',
        value: summary.activityLabel ?? notSet,
        muted: summary.activityLabel == null,
      ),
      _SummaryRow(
        icon: Icons.brush_rounded,
        tint: DSColors.tintLavender,
        label: 'Coat',
        value: summary.coatLabel ?? notSet,
        muted: summary.coatLabel == null,
      ),
      _SummaryRow(
        icon: Icons.medical_services_rounded,
        tint: DSColors.tintSky,
        label: 'Neuter status',
        value: summary.neuterLabel ?? notSet,
        muted: summary.neuterLabel == null,
      ),
      _SummaryRow(
        icon: Icons.pets_rounded,
        tint: DSColors.tintCoral,
        label: 'Breed',
        value: summary.breed ?? notSet,
        muted: summary.breed == null,
      ),
      _SummaryRow(
        icon: Icons.favorite_rounded,
        tint: DSColors.coralSurface,
        label: 'Health conditions',
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
          const _HintCallout(
            title: 'Profile ready',
            body: "You can edit these details anytime in your cat's profile.",
          ),
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

/// Green "good to know" callout at the top of the summary card.
class _HintCallout extends StatelessWidget {
  final String title;
  final String body;

  const _HintCallout({required this.title, required this.body});

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
                Icons.check_circle_rounded,
                color: DSColors.accentSuccess,
                size: 20,
              ),
              const SizedBox(width: DSDimens.sizeXxs),
              Text(
                title,
                style: DSTextStyles.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSDimens.sizeXxs),
          Text(
            body,
            style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkSecondary),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final String label;
  final String value;

  /// Renders the value in a muted colour (e.g. for a "Not set" placeholder).
  final bool muted;

  const _SummaryRow({
    required this.icon,
    required this.tint,
    required this.label,
    required this.value,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(DSRadii.md),
          ),
          child: Icon(icon, size: 20, color: DSColors.inkPrimary),
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
