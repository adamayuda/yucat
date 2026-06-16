import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/cat/presentation/utils/cat_product_recommendations.dart';
import 'package:yucat/features/cat_create/presentation/models/cat_summary.dart';
import 'package:yucat/features/home/widgets/home_loading_page.dart';
import 'package:yucat/features/onboarding/widgets/locked_picks_teaser.dart';
import 'package:yucat/features/product/domain/usecases/fetch_product_by_image_usecase.dart';
import 'package:yucat/features/product_detail/presentation/mappers/product_entity_to_model_mapper.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/utils/cat_product_assessment.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/service_locator.dart';

enum _Phase { intro, scanning, verdict, error }

/// Onboarding "what are you feeding?" step — scans the cat's current food,
/// critiques the real product, then teases the (locked) better picks before the
/// paywall.
class CurrentFoodScreen extends StatefulWidget {
  final CatSummary summary;

  /// Finalizes onboarding (→ paywall). Called by the unlock CTA and by Skip.
  final VoidCallback onStart;

  const CurrentFoodScreen({
    super.key,
    required this.summary,
    required this.onStart,
  });

  @override
  State<CurrentFoodScreen> createState() => _CurrentFoodScreenState();
}

class _CurrentFoodScreenState extends State<CurrentFoodScreen> {
  _Phase _phase = _Phase.intro;
  String _imageB64 = '';
  ProductDisplayModel? _product;
  String? _personalCon;
  int _pickCount = 0;

  void _openScanner() {
    context.router.push(ScannerRoute(onCaptured: _onScanned));
  }

  void _onScanned(String imageBase64, String mimeType) {
    setState(() {
      _phase = _Phase.scanning;
      _imageB64 = imageBase64;
    });
    _runScan(imageBase64, mimeType);
  }

  Future<void> _runScan(String imageBase64, String mimeType) async {
    final l10n = AppLocalizations.of(context);
    sl<LogEventUsecase>().call(eventName: 'Onboarding Scan Captured', properties: {
      'timestamp': DateTime.now().toIso8601String(),
    });
    try {
      final entity = await sl<FetchProductByImageUsecase>()
          .call(imageBase64: imageBase64, mimeType: mimeType);
      if (!mounted) return;
      if (entity == null) {
        _fail(l10n);
        return;
      }
      final model = sl<ProductEntityToModelMapper>()(entity);
      final assessment =
          evaluateCatProduct(widget.summary.entity, model, l10n);
      final picks =
          await recommendProductsForCat(widget.summary.entity, l10n, limit: 3);
      if (!mounted) return;
      setState(() {
        _product = model;
        _personalCon = assessment.cons.isNotEmpty
            ? assessment.cons.first.text
            : null;
        _pickCount = picks.length;
        _phase = _Phase.verdict;
      });
      sl<LogEventUsecase>().call(eventName: 'Onboarding Scan Verdict',
          properties: {
            'product': model.name,
            'score': model.score,
            'pick_count': picks.length,
            'timestamp': DateTime.now().toIso8601String(),
          });
    } catch (_) {
      if (mounted) _fail(l10n);
    }
  }

  void _fail(AppLocalizations l10n) {
    sl<LogEventUsecase>().call(eventName: 'Onboarding Scan Failed', properties: {
      'timestamp': DateTime.now().toIso8601String(),
    });
    setState(() => _phase = _Phase.error);
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == _Phase.scanning) {
      return Scaffold(
        backgroundColor: DSColors.tintCloud,
        body: HomeLoadingWidget(imageBase64: _imageB64),
      );
    }

    final l10n = AppLocalizations.of(context);
    final name = widget.summary.name.trim();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration:
            const BoxDecoration(gradient: DSGradients.onboardingHealthIntro),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: DSDimens.sizeL),
                Text(l10n.onboardingScanTitle(name),
                    style: DSTextStyles.displayLg),
                const SizedBox(height: DSDimens.sizeXs),
                Text(
                  _phase == _Phase.verdict
                      ? l10n.onboardingScanVerdictIntro
                      : l10n.onboardingScanSubtitle,
                  style: DSTextStyles.bodyMd
                      .copyWith(color: DSColors.inkSecondary),
                ),
                const SizedBox(height: DSDimens.sizeL),
                Expanded(child: _body(l10n, name)),
                _footer(l10n, name),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(AppLocalizations l10n, String name) {
    switch (_phase) {
      case _Phase.verdict:
        return ListView(
          children: [
            if (_product != null)
              _ProductVerdictCard(
                product: _product!,
                catName: name,
                personalCon: _personalCon,
              ),
            const SizedBox(height: DSDimens.sizeS),
            LockedPicksTeaser(
              catName: name,
              count: _pickCount == 0 ? 3 : _pickCount,
            ),
            const SizedBox(height: DSDimens.sizeL),
          ],
        );
      case _Phase.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.image_not_supported_outlined,
                  size: 40, color: DSColors.inkTertiary),
              const SizedBox(height: DSDimens.sizeS),
              Text(l10n.onboardingScanFailed,
                  textAlign: TextAlign.center,
                  style: DSTextStyles.bodyLg
                      .copyWith(color: DSColors.inkSecondary)),
            ],
          ),
        );
      case _Phase.intro:
      case _Phase.scanning:
        return Center(
          child: Icon(Icons.qr_code_scanner_rounded,
              size: 96, color: DSColors.inkPrimary.withValues(alpha: 0.15)),
        );
    }
  }

  Widget _footer(AppLocalizations l10n, String name) {
    return Padding(
      padding: const EdgeInsets.only(
        top: DSDimens.sizeS,
        bottom: DSDimens.size3xl,
      ),
      child: switch (_phase) {
        _Phase.verdict => DSPillButton(
            label: l10n.onboardingBrandUnlockCta(name),
            onPressed: widget.onStart,
          ),
        _Phase.error => Column(
            children: [
              DSPillButton(
                label: l10n.onboardingScanRetry,
                onPressed: _openScanner,
                showChevron: false,
              ),
              const SizedBox(height: DSDimens.sizeXs),
              _SkipLink(onTap: widget.onStart, label: l10n.onboardingScanSkip),
            ],
          ),
        _ => Column(
            children: [
              DSPillButton(
                label: l10n.onboardingScanCta,
                onPressed: _openScanner,
                leadingIcon: Icons.camera_alt_rounded,
                showChevron: false,
              ),
              const SizedBox(height: DSDimens.sizeXs),
              _SkipLink(onTap: widget.onStart, label: l10n.onboardingScanSkip),
            ],
          ),
      },
    );
  }
}

class _SkipLink extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const _SkipLink({required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: DSTextStyles.bodyMd.copyWith(
          color: DSColors.inkSecondary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

/// Critique card for the scanned product — its quality score, ingredient cons,
/// and a personalized "for {cat}" concern.
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
