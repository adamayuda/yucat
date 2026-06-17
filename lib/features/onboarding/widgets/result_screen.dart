import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/presentation/utils/cat_product_recommendations.dart';
import 'package:yucat/features/cat_create/presentation/models/cat_summary.dart';
import 'package:yucat/features/onboarding/widgets/locked_picks_teaser.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/utils/cat_product_assessment.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

/// The onboarding success reveal (last beat before the paywall): a compact cat
/// recap, why the scanned food isn't ideal for this cat (when one was scanned),
/// and the locked recommendations. CTA finalizes onboarding (→ paywall) via
/// [onStart].
class ResultScreen extends StatefulWidget {
  final void Function(BuildContext context) onStart;
  final CatSummary summary;

  /// The product the user scanned on the previous step, or null if skipped.
  final ProductDisplayModel? scannedProduct;

  const ResultScreen({
    super.key,
    required this.onStart,
    required this.summary,
    required this.scannedProduct,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  static const _bg = DSColors.tintCloud;

  bool _loaded = false;
  int _pickCount = 3;
  String? _personalCon;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _load();
  }

  Future<void> _load() async {
    final l10n = AppLocalizations.of(context);
    final product = widget.scannedProduct;
    if (product != null) {
      final a = evaluateCatProduct(widget.summary.entity, product, l10n);
      _personalCon = a.cons.isNotEmpty ? a.cons.first.text : null;
    }
    final picks =
        await recommendProductsForCat(widget.summary.entity, l10n, limit: 3);
    if (!mounted) return;
    setState(() => _pickCount = picks.isEmpty ? 3 : picks.length);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = widget.summary.name.trim();
    final product = widget.scannedProduct;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: DSGradients.onboardingSuccess),
        child: Stack(
          children: [
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.onboardingResultTitle(name),
                        textAlign: TextAlign.center,
                        style: DSTextStyles.displayHero,
                      ),
                      const SizedBox(height: DSDimens.sizeS),
                      Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            SvgPicture.asset('assets/images/cat-laught.svg',
                                height: 180),
                            const Positioned(
                                top: 4, right: 36, child: _Sparkle(size: 36)),
                            const Positioned(
                                top: 70, left: 30, child: _Sparkle(size: 22)),
                          ],
                        ),
                      ),
                      const SizedBox(height: DSDimens.sizeL),
                      _RecapCard(summary: widget.summary),
                      if (product != null) ...[
                        const SizedBox(height: DSDimens.sizeL),
                        Text(l10n.onboardingResultWhyTitle(name),
                            style: DSTextStyles.titleMd),
                        const SizedBox(height: DSDimens.sizeS),
                        _ProductVerdictCard(
                          product: product,
                          catName: name,
                          personalCon: _personalCon,
                        ),
                      ],
                      const SizedBox(height: DSDimens.sizeL),
                      LockedPicksTeaser(catName: name, count: _pickCount),
                    ],
                  ),
                ),
              ),
            ),
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
                      label: l10n.onboardingBrandUnlockCta(name),
                      onPressed: () => widget.onStart(context),
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

class _RecapCard extends StatelessWidget {
  final CatSummary summary;

  const _RecapCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notSet = l10n.onboardingSuccessNotSet;
    final healthValue = summary.healthLabels.isEmpty
        ? l10n.onboardingSuccessNone
        : summary.healthLabels.join(', ');

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
  final String iconAsset;
  final String label;
  final String value;
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
            child: SvgPicture.asset('assets/images/$iconAsset',
                width: 36, height: 36),
          ),
        ),
        const SizedBox(width: DSDimens.sizeS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: DSTextStyles.caption
                      .copyWith(color: DSColors.inkTertiary)),
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

/// Critique card for the scanned product — quality score, ingredient cons, and a
/// personalized per-cat concern.
class _ProductVerdictCard extends StatelessWidget {
  final ProductDisplayModel product;
  final String catName;
  final String? personalCon;

  const _ProductVerdictCard({
    required this.product,
    required this.catName,
    this.personalCon,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (product.ratingColor) {
      ProductRatingColor.green => (
          DSColors.accentSuccessSoft,
          DSColors.accentSuccess,
        ),
      ProductRatingColor.yellow => (
          const Color(0xFFFFF3D6),
          const Color(0xFFB37800),
        ),
      ProductRatingColor.red => (DSColors.coralSurface, DSColors.accentDanger),
    };
    final cons = product.cons.take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSDimens.sizeS),
      decoration: BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.lg),
        boxShadow: DSShadows.e1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: DSTextStyles.titleMd,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    if (product.brand.isNotEmpty)
                      Text(product.brand,
                          style: DSTextStyles.bodyMd
                              .copyWith(color: DSColors.inkSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: DSDimens.sizeXs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSDimens.sizeXs,
                  vertical: DSDimens.sizeXxxs,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(DSRadii.pill),
                ),
                child: Text('${product.score}/100',
                    style: DSTextStyles.caption
                        .copyWith(color: fg, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          if (cons.isNotEmpty) const SizedBox(height: DSDimens.sizeS),
          for (final c in cons) ...[
            _Point(text: c),
            const SizedBox(height: DSDimens.sizeXxs),
          ],
          if (personalCon != null) ...[
            const SizedBox(height: DSDimens.sizeXxs),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DSDimens.sizeXs),
              decoration: BoxDecoration(
                color: DSColors.coralSurface,
                borderRadius: BorderRadius.circular(DSRadii.md),
              ),
              child: Text(
                AppLocalizations.of(context)
                    .onboardingScanPersonalCon(catName, personalCon!),
                style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkPrimary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Point extends StatelessWidget {
  final String text;

  const _Point({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.remove_circle_rounded,
              size: 16, color: DSColors.accentDanger),
        ),
        const SizedBox(width: DSDimens.sizeXxs),
        Expanded(
          child: Text(text,
              style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkPrimary)),
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
