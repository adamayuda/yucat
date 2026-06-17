import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/cat/presentation/utils/cat_product_recommendations.dart';
import 'package:yucat/features/cat_create/presentation/models/cat_summary.dart';
import 'package:yucat/features/home/widgets/home_loading_page.dart';
import 'package:yucat/features/product/domain/usecases/fetch_product_by_image_usecase.dart';
import 'package:yucat/features/product_detail/presentation/mappers/product_entity_to_model_mapper.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/service_locator.dart';

enum _Phase { intro, scanning, error }

/// Onboarding scan step (first beat after cat creation): scan the cat's current
/// food, then hand the result to the success screen. Skipping (or a failed
/// scan) still continues to the success screen, just without a product critique.
class CurrentFoodScreen extends StatefulWidget {
  final CatSummary summary;
  final void Function(BuildContext context) onStart;

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
        _fail();
        return;
      }
      final model = sl<ProductEntityToModelMapper>()(entity);
      // Warm the per-cat picks cache so the success teaser is instant.
      unawaited(recommendProductsForCat(widget.summary.entity, l10n, limit: 3));
      sl<LogEventUsecase>().call(eventName: 'Onboarding Scan Verdict',
          properties: {
            'product': model.name,
            'score': model.score,
            'timestamp': DateTime.now().toIso8601String(),
          });
      _goToSuccess(model);
    } catch (_) {
      if (mounted) _fail();
    }
  }

  void _fail() {
    sl<LogEventUsecase>().call(eventName: 'Onboarding Scan Failed', properties: {
      'timestamp': DateTime.now().toIso8601String(),
    });
    setState(() => _phase = _Phase.error);
  }

  void _goToSuccess(ProductDisplayModel? product) {
    context.router.replace(
      ResultRoute(
        summary: widget.summary,
        scannedProduct: product,
        onStart: widget.onStart,
      ),
    );
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
    final isError = _phase == _Phase.error;

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
                  isError ? l10n.onboardingScanFailed : l10n.onboardingScanSubtitle,
                  style: DSTextStyles.bodyMd
                      .copyWith(color: DSColors.inkSecondary),
                ),
                Expanded(
                  child: Center(
                    child: Icon(
                      isError
                          ? Icons.image_not_supported_outlined
                          : Icons.qr_code_scanner_rounded,
                      size: 96,
                      color: DSColors.inkPrimary.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: DSDimens.sizeS,
                    bottom: DSDimens.size3xl,
                  ),
                  child: Column(
                    children: [
                      DSPillButton(
                        label: isError
                            ? l10n.onboardingScanRetry
                            : l10n.onboardingScanCta,
                        onPressed: _openScanner,
                        leadingIcon: Icons.camera_alt_rounded,
                        showChevron: false,
                      ),
                      const SizedBox(height: DSDimens.sizeXs),
                      TextButton(
                        onPressed: () => _goToSuccess(null),
                        child: Text(
                          l10n.onboardingScanSkip,
                          style: DSTextStyles.bodyMd.copyWith(
                            color: DSColors.inkSecondary,
                            decoration: TextDecoration.underline,
                          ),
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
    );
  }
}
