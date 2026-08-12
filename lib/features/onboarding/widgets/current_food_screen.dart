import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
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
    // Read before the first await — context lookups after an async gap are
    // unsafe if the screen has been disposed.
    final locale = Localizations.localeOf(context).languageCode;
    sl<LogEventUsecase>().call(
      eventName: AnalyticsEvents.onboardingScanCaptured,
      properties: {'timestamp': DateTime.now().toIso8601String()},
    );
    try {
      final entity = await sl<FetchProductByImageUsecase>().call(
        imageBase64: imageBase64,
        mimeType: mimeType,
        // Device region (e.g. "ES") to bias backend web_search to the user's
        // market — same source as the main scan flow.
        countryCode:
            WidgetsBinding.instance.platformDispatcher.locale.countryCode,
        // App language for translated product copy — the resolved app locale,
        // not the device one. Same rationale as scanner_page.
        locale: locale,
      );
      if (!mounted) return;
      if (entity == null) {
        _fail('not_found');
        return;
      }
      final model = sl<ProductEntityToModelMapper>()(entity);
      // Warm the per-cat picks cache so the success teaser is instant.
      unawaited(recommendProductsForCat(widget.summary.entity, l10n, limit: 3));
      sl<LogEventUsecase>().call(
        eventName: AnalyticsEvents.onboardingScanSucceeded,
        properties: {
          'product': model.name,
          'score': model.score,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      _goToSuccess(model);
    } catch (e) {
      if (mounted) _fail(_errorType(e), message: e.toString());
    }
  }

  void _fail(String errorType, {String? message}) {
    sl<LogEventUsecase>().call(
      eventName: AnalyticsEvents.onboardingScanFailed,
      properties: {
        'error_type': errorType,
        if (message != null) 'error_message': message,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    setState(() => _phase = _Phase.error);
  }

  /// Classifies a scan exception into a coarse error type. Mirrors
  /// `HomeBloc._toErrorType` (string-based so no cloud_functions import is
  /// needed — the FirebaseFunctions timeout code shows up in `toString()`).
  String _errorType(Object e) {
    final message = e.toString();
    if (message.contains('deadline-exceeded') ||
        message.contains('DEADLINE_EXCEEDED')) {
      return 'timeout';
    }
    if (message.contains('network') ||
        message.contains('SocketException') ||
        message.contains('Connection')) {
      return 'no_internet';
    }
    return 'error';
  }

  void _onSkip() {
    sl<LogEventUsecase>().call(
      eventName: AnalyticsEvents.onboardingScanSkipped,
      properties: {
        'phase': _phase == _Phase.error ? 'error' : 'intro',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    _goToSuccess(null);
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
    final isError = _phase == _Phase.error;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: DSGradients.onboardingCurrentFood,
        ),
        child: Stack(
          children: [
            // Decorative stars + flowers scattered in the margins, behind the
            // content. White ones sit on the purple top; lavender (C2A5E4)
            // ones read against the lighter lower half.
            const _Decor(
              asset: 'star-sharp.svg',
              size: 44,
              color: Colors.white,
              top: 70,
              right: 18,
            ),
            const _Decor(
              asset: 'flower.svg',
              size: 22,
              color: Colors.white,
              top: 150,
              left: 28,
              rotation: 0.3,
            ),
            const _Decor(
              asset: 'flower.svg',
              size: 16,
              color: Color(0xFFC2A5E4),
              top: 250,
              right: 36,
              rotation: -0.2,
            ),
            const _Decor(
              asset: 'star-sharp.svg',
              size: 30,
              color: Color(0xFFC2A5E4),
              bottom: 220,
              left: 20,
            ),
            const _Decor(
              asset: 'flower.svg',
              size: 20,
              color: Color(0xFFC2A5E4),
              bottom: 160,
              right: 28,
              rotation: 0.4,
            ),
            const _Decor(
              asset: 'star-sharp.svg',
              size: 26,
              color: Colors.white,
              top: 120,
              right: 60,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: DSDimens.sizeL),
                    Text(
                      isError
                          ? l10n.onboardingScanFailed
                          : l10n.onboardingScanTitle,
                      textAlign: TextAlign.center,
                      style: DSTextStyles.displayHero,
                    ),
                    Expanded(
                      child: Center(
                        child: ExcludeSemantics(
                          child: SvgPicture.asset(
                            'assets/images/cat_phone.svg',
                            width: 300,
                          ),
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
                          TextButton(
                            onPressed: _onSkip,
                            style: TextButton.styleFrom(
                              overlayColor: Colors.transparent,
                            ),
                            child: Text(
                              l10n.onboardingScanSkip,
                              style: DSTextStyles.label.copyWith(
                                color: DSColors.inkSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: DSDimens.sizeXs),
                          DSPillButton(
                            label: isError
                                ? l10n.onboardingScanRetry
                                : l10n.onboardingScanCta,
                            onPressed: _openScanner,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A recolored decorative SVG (star / flower) pinned in the screen margins.
class _Decor extends StatelessWidget {
  final String asset;
  final double size;
  final Color color;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double rotation;

  const _Decor({
    required this.asset,
    required this.size,
    required this.color,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.rotation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: ExcludeSemantics(
        child: Transform.rotate(
          angle: rotation,
          child: SvgPicture.asset(
            'assets/images/$asset',
            width: size,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
