import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/ensure_signed_in_usecase.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/domain/usecases/get_cats_usecase.dart';
import 'package:yucat/features/home/bloc/home_event.dart';
import 'package:yucat/features/home/bloc/home_state.dart';
import 'package:yucat/features/litter_detail/presentation/mappers/litter_entity_to_model_mapper.dart';
import 'package:yucat/features/product/domain/entities/label_target.dart';
import 'package:yucat/features/product/domain/entities/product_entity.dart';
import 'package:yucat/features/product/domain/entities/scan_exception.dart';
import 'package:yucat/features/product/domain/entities/scan_result_entity.dart';
import 'package:yucat/features/product/domain/usecases/analyze_product_label_usecase.dart';
import 'package:yucat/features/product/domain/usecases/fetch_product_by_image_usecase.dart';
import 'package:yucat/features/product_detail/presentation/mappers/product_entity_to_model_mapper.dart';
import 'package:yucat/features/scan_history/domain/usecases/add_litter_to_history_usecase.dart';
import 'package:yucat/features/scan_history/domain/usecases/add_scan_to_history_usecase.dart';
import 'package:yucat/services/notification_service.dart';
import 'package:yucat/services/review_prompt_service.dart';
import 'package:yucat/services/user_analytics_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FetchProductByImageUsecase _fetchProductByImageUsecase;
  final AnalyzeProductLabelUsecase _analyzeProductLabelUsecase;
  final ProductEntityToModelMapper _productEntityToModelMapper;
  final LitterEntityToModelMapper _litterEntityToModelMapper;
  final EnsureSignedInUsecase _ensureSignedInUsecase;
  final ReviewPromptService _reviewPromptService;
  final GetCatsUsecase _getCatsUsecase;
  final AddScanToHistoryUsecase _addScanToHistoryUsecase;
  final AddLitterToHistoryUsecase _addLitterToHistoryUsecase;
  final LogEventUsecase _logEventUsecase;
  final NotificationService _notificationService;
  final UserAnalyticsService _userAnalyticsService;
  // ignore: unused_field
  final SharedPreferences _prefs;

  /// Bumped on every scan start and on Cancel. A handler that awaited the
  /// backend compares the generation it captured against this after *every*
  /// await; a mismatch means the user abandoned that scan (or started a new
  /// one), so the stale result is dropped instead of pushing a detail page
  /// over whatever they are doing now.
  int _scanGeneration = 0;
  DateTime? _scanStartedAt;
  ScanMode _scanMode = ScanMode.pack;

  HomeBloc({
    required FetchProductByImageUsecase fetchProductByImageUsecase,
    required AnalyzeProductLabelUsecase analyzeProductLabelUsecase,
    required ProductEntityToModelMapper productEntityToModelMapper,
    required LitterEntityToModelMapper litterEntityToModelMapper,
    required EnsureSignedInUsecase ensureSignedInUsecase,
    required ReviewPromptService reviewPromptService,
    required GetCatsUsecase getCatsUsecase,
    required AddScanToHistoryUsecase addScanToHistoryUsecase,
    required AddLitterToHistoryUsecase addLitterToHistoryUsecase,
    required LogEventUsecase logEventUsecase,
    required NotificationService notificationService,
    required UserAnalyticsService userAnalyticsService,
    required SharedPreferences prefs,
  }) : _fetchProductByImageUsecase = fetchProductByImageUsecase,
       _analyzeProductLabelUsecase = analyzeProductLabelUsecase,
       _productEntityToModelMapper = productEntityToModelMapper,
       _litterEntityToModelMapper = litterEntityToModelMapper,
       _ensureSignedInUsecase = ensureSignedInUsecase,
       _reviewPromptService = reviewPromptService,
       _getCatsUsecase = getCatsUsecase,
       _addScanToHistoryUsecase = addScanToHistoryUsecase,
       _addLitterToHistoryUsecase = addLitterToHistoryUsecase,
       _logEventUsecase = logEventUsecase,
       _notificationService = notificationService,
       _userAnalyticsService = userAnalyticsService,
       _prefs = prefs,
       super(HomeHiddenState()) {
    on<HomeInitialEvent>(_onHomeInitialEvent);
    on<ImageCapturedEvent>(_onImageCapturedEvent);
    on<LabelImageCapturedEvent>(_onLabelImageCaptured);
    on<ScanAbandonedEvent>(_onScanAbandoned);
  }

  Future<void> _onHomeInitialEvent(
    HomeInitialEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoadingState());

    final user = await _ensureSignedInUsecase();

    // Bind the anonymous Firebase UID as the Mixpanel distinct id so People
    // properties attach to a stable profile (idempotent per session).
    //
    // OneSignal.login used to happen here too; it moved to SplashBloc, which
    // runs before onboarding — Home is only reached by users who already
    // converted, so identifying here left every drop-off anonymous.
    if (user != null) {
      unawaited(_userAnalyticsService.identify(user.uid));
    }

    List<CatEntity> cats = const [];
    if (user != null) {
      try {
        cats = await _getCatsUsecase(userId: user.uid);
        // Authoritative cats sync — home loads on every return to the tab, so
        // this corrects the People profile after creates/deletes elsewhere.
        unawaited(_userAnalyticsService.syncCats(
          count: cats.length,
          primaryAgeGroup: cats.isNotEmpty ? cats.first.ageGroup : null,
          primaryBreed: cats.isNotEmpty ? cats.first.breed : null,
        ));
      } catch (_) {
        // Header falls back to generic copy on read failure.
      }
    }

    debugPrint('CATDIAG home loaded cats='
        '${cats.map((c) => '${c.name}:breed=${c.breed}:health=${c.healthConditions}').toList()}');
    emit(HomeLoadedState(cats: cats));
  }

  Future<void> _onImageCapturedEvent(
    ImageCapturedEvent event,
    Emitter<HomeState> emit,
  ) async {
    _logEventUsecase.call(
      eventName: AnalyticsEvents.productImageCaptured,
      properties: {
        'mime_type': event.mimeType,
        'capture_source': event.captureSource,
        'has_barcode': event.gtin != null,
        if (event.barcodeFormat != null) 'barcode_format': event.barcodeFormat,
        if (event.imageBytes != null) 'image_bytes': event.imageBytes,
        if (event.prepMs != null) 'prep_ms': event.prepMs,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    final gen = _beginScan(ScanMode.pack);
    emit(HomeScanningState(imageBase64: event.imageBase64));

    // Wall-clock from shutter to result. The backend can fan out to four
    // parallel sources and web search, so `deadline-exceeded` is a real,
    // already-classified error type — without a duration on the outcome there
    // is no way to see the distribution creeping toward the timeout.
    final startedAt = DateTime.now();
    int elapsedMs() => DateTime.now().difference(startedAt).inMilliseconds;

    try {
      final scan = await _fetchProductByImageUsecase.call(
        imageBase64: event.imageBase64,
        mimeType: event.mimeType,
        countryCode: event.countryCode,
        locale: event.locale,
        gtin: event.gtin,
      );
      if (gen != _scanGeneration) return;

      // The backend says *why* a scan failed; the error view renders one
      // layout per outcome with the exit that fixes it, and analytics separate
      // "not a cat product" from "unreadable pack" from "identified but no
      // data" — three problems with three fixes.
      if (scan is ScanNotIdentified || scan is ScanAnalysisFailed) {
        final outcome = switch (scan) {
          ScanNotIdentified(notCatProduct: true) => 'not_cat_product',
          ScanNotIdentified() => 'unreadable',
          ScanAnalysisFailed(isLitter: true) => 'litter_analysis_failed',
          _ => 'analysis_failed',
        };
        final reason = scan is ScanNotIdentified ? scan.reason : null;
        final identification =
            scan is ScanAnalysisFailed ? scan.identification : null;
        final productKey = scan is ScanAnalysisFailed ? scan.productKey : null;
        _logEventUsecase.call(
          eventName: AnalyticsEvents.productImageScanFailed,
          properties: {
            'error_type': outcome,
            if (reason != null) 'reason': reason,
            'has_barcode': event.gtin != null,
            'path': scan.path,
            if (scan.identifyModel != null) 'identify_model': scan.identifyModel,
            'duration_ms': elapsedMs(),
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        emit(HomeErrorState(
          errorType: HomeErrorType.notFound,
          outcome: outcome,
          reason: reason,
          identifiedBrand: identification?.brand,
          identifiedName: identification?.name,
          productKey: productKey,
          gtin: scan.gtin,
        ));
        return;
      }

      // The camera is one entry point for both categories — the backend decides
      // which it was, and the two results have their own screens and stores.
      if (scan is ScanLitterResult) {
        await _onLitterScanned(scan, event, durationMs: elapsedMs(), gen: gen);
        return;
      }

      // ScanLabelFailed cannot come back from the pack callable; the sealed
      // switch above covers the other failures, so this is the food success.
      final food = scan as ScanFoodResult;
      await _onFoodResolved(
        food.product,
        path: food.path,
        hasBarcode: event.gtin != null,
        durationMs: elapsedMs(),
        router: event.router,
        gen: gen,
        identifyModel: food.identifyModel,
      );
    } catch (e) {
      if (gen != _scanGeneration) return;
      // The callable code is the error type — `deadline-exceeded`,
      // `unavailable`, `resource-exhausted`, `internal`… — so failures are
      // diagnosable by kind in Mixpanel instead of one `error` bucket.
      final code = e is ScanException ? e.code : e.runtimeType.toString();
      _logEventUsecase.call(
        eventName: AnalyticsEvents.productImageScanFailed,
        properties: {
          'error_type': code,
          'error_message': e.toString(),
          'duration_ms': elapsedMs(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (code == 'unauthenticated') {
        // The anonymous session lapsed (token refresh failed, App Check…).
        // Re-establish it now so the user's retry is not refused again.
        unawaited(_ensureSignedInUsecase());
      }
      emit(HomeErrorState(errorType: _toErrorType(e)));
    }
  }

  /// The back-label rescue: same theater, one vision call instead of the
  /// search fan-out, and the result is a full product that takes exactly the
  /// path a scanned one does (history, `Product Selected`, review gate,
  /// detail page) — which is why HomeBloc owns it rather than the detail bloc.
  Future<void> _onLabelImageCaptured(
    LabelImageCapturedEvent event,
    Emitter<HomeState> emit,
  ) async {
    final gen = _beginScan(ScanMode.label);
    emit(HomeScanningState(
      imageBase64: event.imageBase64,
      mode: ScanMode.label,
    ));
    final startedAt = DateTime.now();
    int elapsedMs() => DateTime.now().difference(startedAt).inMilliseconds;

    Map<String, Object?> completedProps(String outcome, {String? model}) => {
          'outcome': outcome,
          'has_product_key': event.target.productKey != null,
          'has_gtin': event.target.gtin != null,
          if (model != null) 'label_model': model,
          'duration_ms': elapsedMs(),
          'timestamp': DateTime.now().toIso8601String(),
        };

    try {
      final scan = await _analyzeProductLabelUsecase.call(
        imageBase64: event.imageBase64,
        mimeType: event.mimeType,
        target: event.target,
        countryCode: event.countryCode,
        locale: event.locale,
      );
      if (gen != _scanGeneration) return;

      if (scan is ScanFoodResult) {
        _logEventUsecase.call(
          eventName: AnalyticsEvents.labelScanCompleted,
          properties: completedProps('product', model: scan.analyzeModel),
        );
        await _onFoodResolved(
          scan.product,
          path: scan.path,
          hasBarcode: event.target.gtin != null,
          durationMs: elapsedMs(),
          router: event.router,
          gen: gen,
          labelModel: scan.analyzeModel,
        );
        return;
      }

      // Anything else is a label failure. `ScanLabelFailed` is the expected
      // shape; the generic variants only arrive from an older backend.
      final failed = scan is ScanLabelFailed ? scan : null;
      final noData = failed?.noData ?? false;
      final outcome = noData ? 'label_no_data' : 'label_unreadable';
      _logEventUsecase.call(
        eventName: AnalyticsEvents.labelScanCompleted,
        properties: completedProps(outcome, model: scan.analyzeModel),
      );
      emit(HomeErrorState(
        errorType:
            noData ? HomeErrorType.labelNoData : HomeErrorType.labelUnreadable,
        outcome: outcome,
        identifiedBrand: failed?.identification?.brand ?? event.target.brand,
        identifiedName: failed?.identification?.name ?? event.target.name,
        productKey: failed?.productKey ?? event.target.productKey,
        gtin: failed?.gtin ?? event.target.gtin,
      ));
    } catch (e) {
      if (gen != _scanGeneration) return;
      final code = e is ScanException ? e.code : e.runtimeType.toString();
      _logEventUsecase.call(
        eventName: AnalyticsEvents.labelScanCompleted,
        properties: {...completedProps(code), 'error_message': e.toString()},
      );
      if (code == 'unauthenticated') unawaited(_ensureSignedInUsecase());
      emit(HomeErrorState(errorType: _toErrorType(e)));
    }
  }

  /// Cancel on the loading screen. Invalidates the in-flight scan (its result
  /// is dropped when it lands — the backend still finishes and caches it) and
  /// returns Home to the dashboard.
  Future<void> _onScanAbandoned(
    ScanAbandonedEvent event,
    Emitter<HomeState> emit,
  ) async {
    final startedAt = _scanStartedAt;
    _scanGeneration++;
    _logEventUsecase.call(
      eventName: AnalyticsEvents.scanAbandoned,
      properties: {
        'kind': _scanMode.name,
        'elapsed_ms': startedAt == null
            ? 0
            : DateTime.now().difference(startedAt).inMilliseconds,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    add(HomeInitialEvent());
  }

  int _beginScan(ScanMode mode) {
    _scanMode = mode;
    _scanStartedAt = DateTime.now();
    return ++_scanGeneration;
  }

  /// The shared success tail for a food result, whichever callable produced
  /// it: local history, `Product Selected`, the scan counters and the review
  /// gate, then the detail page. `gen` is re-checked after the history write —
  /// the one await inside — so a Cancel during it still drops the push.
  Future<void> _onFoodResolved(
    ProductEntity product, {
    required String path,
    required bool hasBarcode,
    required int durationMs,
    required StackRouter router,
    required int gen,
    String? identifyModel,
    String? labelModel,
  }) async {
    final productDetailModel = _productEntityToModelMapper(product);

    // Record every successful scan to local history (best-effort; a
    // persistence failure must never block navigation to the result).
    try {
      await _addScanToHistoryUsecase(productDetailModel);
    } catch (_) {}
    if (gen != _scanGeneration) return;

    _logEventUsecase.call(
      eventName: AnalyticsEvents.productSelected,
      properties: {
        'product_name': productDetailModel.name,
        'product_brand': productDetailModel.brand,
        'source': 'image',
        // The backend's exit — `gtin-hit`, `cache-hit`, `full-analysis`,
        // `label` — is what shows whether each path is earning its keep.
        'path': path,
        'has_barcode': hasBarcode,
        'data_unavailable': productDetailModel.dataUnavailable,
        if (identifyModel != null) 'identify_model': identifyModel,
        if (labelModel != null) 'label_model': labelModel,
        'duration_ms': durationMs,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    unawaited(_userAnalyticsService.recordScan());
    unawaited(_notificationService.setLastScan());
    await _reviewPromptService.recordScan();
    if (gen != _scanGeneration) return;
    // Fire-and-forget; the service applies its own gating.
    unawaited(_reviewPromptService.maybePrompt(trigger: 'post_scan'));

    router.push(ProductDetailRoute(product: productDetailModel));
    add(HomeInitialEvent());
  }

  /// A scanned litter: record it in the litter history and open the litter
  /// screen. Deliberately symmetrical with the food path — a litter scan counts
  /// toward `total_scans` and the review-prompt gate exactly like a food one.
  Future<void> _onLitterScanned(
    ScanLitterResult scan,
    ImageCapturedEvent event, {
    required int durationMs,
    required int gen,
  }) async {
    final litterModel = _litterEntityToModelMapper(scan.litter);

    // Best-effort: a persistence failure must never block the result screen.
    try {
      await _addLitterToHistoryUsecase(litterModel);
    } catch (_) {}
    if (gen != _scanGeneration) return;

    _logEventUsecase.call(
      eventName: AnalyticsEvents.litterSelected,
      properties: {
        'litter_name': litterModel.name,
        'litter_brand': litterModel.brand,
        'litter_material': litterModel.material.wire,
        'source': 'image',
        'path': scan.path,
        'has_barcode': event.gtin != null,
        'duration_ms': durationMs,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    unawaited(_userAnalyticsService.recordScan());
    unawaited(_notificationService.setLastScan());
    await _reviewPromptService.recordScan();
    if (gen != _scanGeneration) return;
    unawaited(_reviewPromptService.maybePrompt(trigger: 'post_scan'));

    event.router.push(LitterDetailRoute(litter: litterModel));
    add(HomeInitialEvent());
  }

  HomeErrorType _toErrorType(Object e) {
    final code = e is ScanException ? e.code : null;
    final message = e.toString();
    if (code == 'deadline-exceeded' || message.contains('DEADLINE_EXCEEDED')) {
      return HomeErrorType.timeout;
    }
    // `unavailable` is what the Functions SDK reports for a device that is
    // offline; the string checks cover the plugin's own transport errors.
    if (code == 'unavailable' ||
        message.contains('network') ||
        message.contains('SocketException') ||
        message.contains('Connection')) {
      return HomeErrorType.noInternet;
    }
    if (code == 'resource-exhausted') {
      return HomeErrorType.serviceBusy;
    }
    return HomeErrorType.generic;
  }
}
