import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:yucat/core/subscription/domain/usecases/has_active_subscription_usecase.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/paywall/bloc/paywall_event.dart';
import 'package:yucat/features/paywall/bloc/paywall_state.dart';
import 'package:yucat/features/paywall/utils/intro_offer_info.dart';
import 'package:yucat/features/paywall/utils/trial_info.dart';
import 'package:yucat/services/notification_service.dart';
import 'package:yucat/services/user_analytics_service.dart';

/// What a package will actually grant *this* user, after the store's
/// eligibility check. Both null when the user qualifies for neither.
typedef _Offers = ({TrialInfo? trial, IntroOfferInfo? intro});

class PaywallBloc extends Bloc<PaywallEvent, PaywallState> {
  /// Custom package identifier of the second-chance plan in the RevenueCat
  /// offering: the same yearly plan sold with a pay-up-front first year
  /// (`com.adam.yucat.app.pro.yearly.offer`). Not a reserved `$rc_` id because
  /// `$rc_annual` is taken by the standard yearly. Absent → no sheet.
  static const secondChancePackageId = 'annual_offer';

  /// How long the discounted first year stays available within one paywall
  /// session, counted from its first presentation. The sheet counts down to
  /// it; at zero the offer and the close chip disappear for the rest of the
  /// session. Per session, not per device: a returning user (or a tap on the
  /// "dropped at paywall" push a day later) gets a fresh window, so the push
  /// never promises something the app then refuses.
  static const secondChanceWindow = Duration(minutes: 10);

  final HasActiveSubscriptionUseCase _hasActiveSubscriptionUseCase;
  final LogEventUsecase _logEventUsecase;
  final UserAnalyticsService _userAnalyticsService;
  final NotificationService _notificationService;

  DateTime? _paywallShownTime;
  /// Whether the user reached the store sheet during this paywall session.
  /// Separates "looked and left" from "tried to buy and backed out" on
  /// `Paywall Dismissed` — two very different abandonment stories.
  bool _ctaTappedThisSession = false;
  /// Which paths have already presented the second-chance sheet this paywall
  /// session — `auto` (unprompted, returning users), `cancel` (after backing
  /// out of Apple's sheet) and `close` (the delayed close chip). Only `auto`
  /// is limited to once; `cancel` and `close` answer a user action and fire
  /// every time, until the session's 10-minute window runs out. Cleared on
  /// every `_onInitial`.
  final Set<String> _secondChanceShown = {};
  /// How the sheet was last opened — stamped on all three second-chance
  /// events so the two paths can be compared; a push that says "€19.99" lands
  /// on the `auto` path.
  String _secondChanceSource = 'cancel';
  String _trigger = 'manual';

  PaywallBloc({
    required HasActiveSubscriptionUseCase hasActiveSubscriptionUseCase,
    required LogEventUsecase logEventUsecase,
    required UserAnalyticsService userAnalyticsService,
    required NotificationService notificationService,
  })  : _hasActiveSubscriptionUseCase = hasActiveSubscriptionUseCase,
        _logEventUsecase = logEventUsecase,
        _userAnalyticsService = userAnalyticsService,
        _notificationService = notificationService,
        super(const PaywallInitialState()) {
    on<PaywallInitialEvent>(_onInitial);
    on<PaywallPackageSelectedEvent>(_onPackageSelected);
    on<PaywallPurchaseEvent>(_onPurchase);
    on<PaywallSecondChanceAcceptedEvent>(_onSecondChanceAccepted);
    on<PaywallSecondChanceDismissedEvent>(_onSecondChanceDismissed);
    on<PaywallSecondChanceRequestedEvent>(_onSecondChanceRequested);
    on<PaywallRestoreEvent>(_onRestore);
    on<PaywallDismissEvent>(_onDismiss);
  }

  Future<void> _onInitial(
    PaywallInitialEvent event,
    Emitter<PaywallState> emit,
  ) async {
    _trigger = event.trigger;
    emit(const PaywallLoadingState());

    if (await _hasActiveSubscriptionUseCase()) {
      emit(const PaywallAlreadySubscribedState());
      return;
    }

    final Offerings offerings;
    try {
      offerings = await Purchases.getOfferings();
    } on PlatformException catch (_) {
      emit(const PaywallErrorState(kind: PaywallError.couldNotLoadPlans));
      return;
    }

    final current = offerings.current;
    if (current == null || current.availablePackages.isEmpty) {
      emit(const PaywallErrorState(kind: PaywallError.noPlansAvailable));
      return;
    }

    // The paywall offers a single annual plan. Weekly is still published in the
    // offering (and still billed for existing subscribers), it's just not shown
    // — flip this filter to bring it back.
    final annualOnly = current.availablePackages
        .where((p) => p.packageType == PackageType.annual)
        .toList();
    // Fall back to the first available package if the offering is
    // misconfigured, so the paywall never renders empty.
    final packages =
        annualOnly.isNotEmpty ? annualOnly : [current.availablePackages.first];
    final selected = packages.first;

    // The downsell for people who back out of the store sheet — 3 in 4 CTA
    // tappers, per Mixpanel: the same yearly plan with a discounted first year.
    // Only worth offering if this user is actually eligible for that intro
    // offer (Apple: one per subscription group, ever), so its eligibility is
    // resolved here, in parallel with the main plan's. Missing package,
    // ineligible user, or the paywall already fell back to a non-annual plan:
    // no sheet, nothing else changes.
    Package? secondChanceCandidate;
    if (selected.packageType == PackageType.annual) {
      for (final p in current.availablePackages) {
        if (p.identifier == secondChancePackageId) {
          secondChanceCandidate = p;
          break;
        }
      }
    }

    // The offers this user will actually receive — null when the product has
    // none configured or the store says they've already used one.
    final resolved = await Future.wait([
      _eligibleOffersFor(selected),
      if (secondChanceCandidate != null)
        _eligibleOffersFor(secondChanceCandidate),
    ]);
    final eligibleTrial = resolved[0].trial;
    final eligibleIntro = resolved[0].intro;
    final secondChanceIntro =
        resolved.length > 1 ? resolved[1].intro : null;
    final secondChance = secondChanceIntro != null ? secondChanceCandidate : null;

    _paywallShownTime = DateTime.now();
    _ctaTappedThisSession = false;
    _secondChanceShown.clear();
    _logEventUsecase.call(
      eventName: AnalyticsEvents.paywallShown,
      properties: {
        'trigger': _trigger,
        'offering': current.identifier,
        'trial_eligible': eligibleTrial != null,
        'trial_days': eligibleTrial?.days,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    // `paywall_seen` is the anchor for the "dropped at paywall" segment: it is
    // set once and never cleared, so pairing it with is_subscriber != true finds
    // everyone who saw the offer and didn't take it.
    _notificationService.setFunnelStage(FunnelStage.paywall);
    _notificationService.setTags({
      NotificationTags.paywallSeen: NotificationTags.boolValue(true),
    });

    final loaded = PaywallLoadedState(
      currentOffering: current,
      packages: packages,
      selectedPackage: selected,
      secondChancePackage: secondChance,
      secondChanceIntro: secondChanceIntro,
      eligibleTrial: eligibleTrial,
      eligibleIntro: eligibleIntro,
    );
    emit(loaded);

    // Returning non-subscribers already declined the full-price plan at least
    // once, and the "dropped at paywall" push promises them the discount — so
    // lead with the offer instead of making them cancel Apple's sheet to find
    // it. Still once per session, still eligibility-gated. The short delay
    // lets the paywall slide in first so the sheet visibly sits on top of it.
    if (_trigger == PaywallTrigger.returningUser && secondChance != null) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (state != loaded) return;
      _presentSecondChance(loaded, emit, source: 'auto');
    }
  }

  /// Open the sheet once per paywall session and record why.
  void _presentSecondChance(
    PaywallLoadedState current,
    Emitter<PaywallState> emit, {
    required String source,
  }) {
    // First presentation this session starts the clock; later ones reuse
    // it. Past it, the offer is gone for the session — the countdown the
    // user saw meant what it said.
    final deadline =
        current.secondChanceDeadline ?? DateTime.now().add(secondChanceWindow);
    if (!DateTime.now().isBefore(deadline)) {
      emit(current.withoutSecondChance());
      return;
    }
    _secondChanceShown.add(source);
    _secondChanceSource = source;
    final next = current.copyWith(
      isPurchasing: false,
      secondChanceTick: current.secondChanceTick + 1,
      secondChanceDeadline: deadline,
    );
    _logEventUsecase.call(
      eventName: AnalyticsEvents.paywallSecondChanceShown,
      properties: _secondChanceProps(next),
    );
    emit(next);
  }

  /// The free trial and/or paid introductory offer [pkg] will actually grant
  /// this user; both null when it offers neither or the user is ineligible.
  ///
  /// The two stores need different eligibility signals:
  ///
  /// * **iOS** — RevenueCat computes StoreKit eligibility for us. We fail closed
  ///   on unknown/ineligible/error/timeout so an ineligible user is never shown
  ///   a trial they can't get.
  /// * **Android** — `checkTrialOrIntroductoryPriceEligibility` *always* returns
  ///   unknown (see the SDK doc on that method), so it's useless here. Google
  ///   Play instead filters offers server-side: an offer restricted to new
  ///   customers simply isn't returned to an ineligible user. So the presence of
  ///   a `freePhase` on the product IS the eligibility signal. This depends on
  ///   the Play offer being configured "new customers only" — see the store
  ///   setup notes in CLAUDE.md.
  Future<_Offers> _eligibleOffersFor(Package pkg) async {
    const none = (trial: null, intro: null);
    final offers = (trial: trialInfoFor(pkg), intro: introOfferFor(pkg));
    if (offers.trial == null && offers.intro == null) return none;

    if (Platform.isAndroid) return offers;

    try {
      final result = await Purchases.checkTrialOrIntroductoryPriceEligibility(
        [pkg.storeProduct.identifier],
      ).timeout(const Duration(seconds: 5));
      final status = result[pkg.storeProduct.identifier]?.status;
      return status == IntroEligibilityStatus.introEligibilityStatusEligible
          ? offers
          : none;
    } catch (e) {
      debugPrint('PaywallBloc.offerEligibility error: $e');
      return none;
    }
  }

  Future<void> _onPackageSelected(
    PaywallPackageSelectedEvent event,
    Emitter<PaywallState> emit,
  ) async {
    final current = state;
    if (current is! PaywallLoadedState || current.isPurchasing) return;
    if (current.selectedPackage.identifier == event.package.identifier) return;
    await _select(event.package, current, emit);
  }

  /// Switch plans, re-resolving the trial for the new package so the CTA, the
  /// disclosure and `is_trial` on the purchase event all describe the plan
  /// actually being bought.
  Future<void> _select(
    Package package,
    PaywallLoadedState current,
    Emitter<PaywallState> emit,
  ) async {
    _logEventUsecase.call(
      eventName: AnalyticsEvents.planSelected,
      properties: {
        'package_id': package.identifier,
        'package_type': package.packageType.name,
        'trigger': _trigger,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    final offers = await _eligibleOffersFor(package);
    emit(current.withSelection(
      package: package,
      eligibleTrial: offers.trial,
      eligibleIntro: offers.intro,
    ));
  }

  Future<void> _onSecondChanceAccepted(
    PaywallSecondChanceAcceptedEvent event,
    Emitter<PaywallState> emit,
  ) async {
    final current = state;
    if (current is! PaywallLoadedState || current.isPurchasing) return;
    final offer = current.secondChancePackage;
    if (offer == null) return;
    _logEventUsecase.call(
      eventName: AnalyticsEvents.paywallSecondChanceTapped,
      properties: _secondChanceProps(current),
    );
    await _select(offer, current, emit);
    await _purchaseSelected(emit);
  }

  void _onSecondChanceDismissed(
    PaywallSecondChanceDismissedEvent event,
    Emitter<PaywallState> emit,
  ) {
    final current = state;
    if (current is! PaywallLoadedState) return;
    if (current.secondChancePackage == null) return;
    _logEventUsecase.call(
      eventName: AnalyticsEvents.paywallSecondChanceDismissed,
      properties: _secondChanceProps(current),
    );
    // The sheet closes itself when the countdown hits zero; that dismissal
    // also retires the offer (and the close chip) for the session.
    final deadline = current.secondChanceDeadline;
    if (deadline != null && !DateTime.now().isBefore(deadline)) {
      emit(current.withoutSecondChance());
    }
  }

  void _onSecondChanceRequested(
    PaywallSecondChanceRequestedEvent event,
    Emitter<PaywallState> emit,
  ) {
    final current = state;
    if (current is! PaywallLoadedState || current.isPurchasing) return;
    if (current.secondChancePackage == null) return;
    _presentSecondChance(current, emit, source: 'close');
  }

  Map<String, Object?> _secondChanceProps(PaywallLoadedState s) {
    final pkg = s.secondChancePackage!;
    return {
      'package_id': pkg.identifier,
      'package_type': pkg.packageType.name,
      'price': pkg.storeProduct.price,
      'intro_price': s.secondChanceIntro?.price,
      'currency': pkg.storeProduct.currencyCode,
      'source': _secondChanceSource,
      'seconds_left': s.secondChanceDeadline
          ?.difference(DateTime.now())
          .inSeconds
          .clamp(0, secondChanceWindow.inSeconds),
      'trigger': _trigger,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<void> _onPurchase(
    PaywallPurchaseEvent event,
    Emitter<PaywallState> emit,
  ) =>
      _purchaseSelected(emit);

  /// Buy whatever [PaywallLoadedState.selectedPackage] is. Shared by the main
  /// CTA and the second-chance sheet so both paths log and gate identically.
  Future<void> _purchaseSelected(Emitter<PaywallState> emit) async {
    final current = state;
    if (current is! PaywallLoadedState || current.isPurchasing) return;

    // Logged after the isPurchasing guard (so a double-tap while the sheet is
    // open counts once) and before the store call (so a sheet that never
    // presents or never resolves is still visible as intent). Carries the same
    // properties as Subscription Completed so both ends of the funnel segment
    // identically.
    _ctaTappedThisSession = true;
    _logEventUsecase.call(
      eventName: AnalyticsEvents.paywallCtaTapped,
      properties: {
        'package_id': current.selectedPackage.identifier,
        'package_type': current.selectedPackage.packageType.name,
        'price': current.selectedPackage.storeProduct.price,
        'currency': current.selectedPackage.storeProduct.currencyCode,
        'trigger': _trigger,
        'is_trial': current.eligibleTrial != null,
        'trial_days': current.eligibleTrial?.days,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    emit(current.copyWith(isPurchasing: true));

    try {
      await Purchases.purchase(
        PurchaseParams.package(current.selectedPackage),
      );
      await Purchases.syncPurchases();

      final isActive =
          await _hasActiveSubscriptionUseCase(forceRefresh: true);

      if (isActive) {
        _logEventUsecase.call(
          eventName: AnalyticsEvents.subscriptionCompleted,
          properties: {
            'package_id': current.selectedPackage.identifier,
            'package_type': current.selectedPackage.packageType.name,
            'price': current.selectedPackage.storeProduct.price,
            'currency':
                current.selectedPackage.storeProduct.currencyCode,
            'trigger': _trigger,
            // Trial starts bill nothing today — downstream revenue reporting
            // needs to tell them apart from immediate purchases.
            'is_trial': current.eligibleTrial != null,
            'trial_days': current.eligibleTrial?.days,
            // A discounted first year bills today, at this price rather than
            // `price` — the second-chance path's signature on this event.
            'is_intro_offer': current.eligibleIntro != null,
            'intro_price': current.eligibleIntro?.price,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        final isTrial = current.eligibleTrial != null;
        _userAnalyticsService.syncSubscription(
          isSubscriber: true,
          isTrial: isTrial,
          trialStartedAt: isTrial ? DateTime.now() : null,
          plan: current.selectedPackage.packageType.name,
          price: current.selectedPackage.storeProduct.price,
          currency: current.selectedPackage.storeProduct.currencyCode,
        );
        _notificationService.setFunnelStage(FunnelStage.subscribed);
        // `is_trial = true` is the trial Journey's entry; the splash gate
        // flips it back off once the trial converts or lapses.
        _notificationService.setSubscriber(true, isTrial: isTrial);
        emit(const PaywallSuccessState(purchasedSubscription: true));
      } else {
        _logPurchaseFailed(reason: 'not_active', packageType: current.selectedPackage.packageType.name);
        emit(current.copyWith(
          isPurchasing: false,
          transientError: PaywallTransientError.purchaseNotComplete,
          errorTick: current.errorTick + 1,
        ));
      }
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        // Backing out of the store sheet is a normal outcome, not a failure.
        // It used to be logged as `Subscription Purchase Failed`, where it
        // outnumbered real errors ~6:1 and made the event useless.
        _logEventUsecase.call(
          eventName: AnalyticsEvents.paywallPurchaseCancelled,
          properties: {
            'package_type': current.selectedPackage.packageType.name,
            'trigger': _trigger,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        // Backing out of the *main* plan's sheet: offer the discounted first
        // year — every time, while the session's window is open. Backing out
        // of the offer's own sheet gets nothing more.
        final offer = current.secondChancePackage;
        final offerSecondChance = offer != null &&
            current.selectedPackage.identifier != offer.identifier;
        if (offerSecondChance) {
          _presentSecondChance(current, emit, source: 'cancel');
          return;
        }
        emit(current.copyWith(isPurchasing: false));
        return;
      }
      _logPurchaseFailed(
        reason: 'platform_error',
        errorCode: code.name,
        errorMessage: e.message,
        packageType: current.selectedPackage.packageType.name,
      );
      emit(current.copyWith(
        isPurchasing: false,
        transientError: PaywallTransientError.purchaseFailed,
        errorTick: current.errorTick + 1,
      ));
    } catch (e) {
      debugPrint('PaywallBloc.purchase error: $e');
      _logPurchaseFailed(
        reason: 'unknown',
        errorMessage: e.toString(),
        packageType: current.selectedPackage.packageType.name,
      );
      emit(current.copyWith(
        isPurchasing: false,
        transientError: PaywallTransientError.somethingWentWrong,
        errorTick: current.errorTick + 1,
      ));
    }
  }

  void _logPurchaseFailed({
    required String reason,
    String? errorCode,
    String? errorMessage,
    String? packageType,
  }) {
    _logEventUsecase.call(
      eventName: AnalyticsEvents.subscriptionPurchaseFailed,
      properties: {
        'reason': reason,
        // The RevenueCat error code — `reason` alone cannot tell a payment
        // decline from a network drop from a store misconfiguration.
        if (errorCode != null) 'error_code': errorCode,
        if (errorMessage != null) 'error_message': errorMessage,
        if (packageType != null) 'package_type': packageType,
        'trigger': _trigger,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> _onRestore(
    PaywallRestoreEvent event,
    Emitter<PaywallState> emit,
  ) async {
    final current = state;
    if (current is! PaywallLoadedState || current.isPurchasing) return;

    _logEventUsecase.call(
      eventName: AnalyticsEvents.paywallRestoreTapped,
      properties: {
        'trigger': _trigger,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    emit(current.copyWith(isPurchasing: true));

    try {
      await Purchases.restorePurchases();
      final isActive =
          await _hasActiveSubscriptionUseCase(forceRefresh: true);

      if (isActive) {
        _logEventUsecase.call(
          eventName: AnalyticsEvents.subscriptionRestored,
          properties: {
            'trigger': _trigger,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        _userAnalyticsService.syncSubscription(isSubscriber: true);
        _notificationService.setFunnelStage(FunnelStage.subscribed);
        _notificationService.setSubscriber(true);
        emit(const PaywallSuccessState(purchasedSubscription: true));
      } else {
        // Nothing to restore is the expected outcome for a first-time user,
        // not a failure — it was 100% of `Subscription Restore Failed`.
        _logEventUsecase.call(
          eventName: AnalyticsEvents.paywallRestoreCompleted,
          properties: {
            'restored': false,
            'trigger': _trigger,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        emit(current.copyWith(
          isPurchasing: false,
          transientError: PaywallTransientError.noActiveSubscription,
          errorTick: current.errorTick + 1,
        ));
      }
    } catch (e) {
      debugPrint('PaywallBloc.restore error: $e');
      _logRestoreFailed(reason: 'error', errorMessage: e.toString());
      emit(current.copyWith(
        isPurchasing: false,
        transientError: PaywallTransientError.restoreFailed,
        errorTick: current.errorTick + 1,
      ));
    }
  }

  void _logRestoreFailed({required String reason, String? errorMessage}) {
    _logEventUsecase.call(
      eventName: AnalyticsEvents.subscriptionRestoreFailed,
      properties: {
        'reason': reason,
        if (errorMessage != null) 'error_message': errorMessage,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  void _onDismiss(
    PaywallDismissEvent event,
    Emitter<PaywallState> emit,
  ) {
    _logPaywallDismissed(ctaTapped: _ctaTappedThisSession);
    emit(const PaywallSuccessState(purchasedSubscription: false));
  }

  /// Fires only when the user leaves **without** converting.
  ///
  /// It used to also fire on purchase/restore success with `cta_tapped: true`,
  /// which made it useless as an abandonment metric — a funnel counting
  /// dismissals had to filter on `cta_tapped` to avoid counting conversions.
  /// Conversions are fully described by `Subscription Completed` /
  /// `Subscription Restored`, and intent by `Paywall CTA Tapped`, so those
  /// calls were removed.
  ///
  /// `cta_tapped` now means "reached the store sheet at some point during this
  /// paywall session, then left anyway" — it was hardcoded `false`, which made
  /// the property inert. True is the more interesting group: they wanted to
  /// buy and something stopped them, and it should track `Paywall Purchase
  /// Cancelled` closely.
  void _logPaywallDismissed({required bool ctaTapped}) {
    final timeViewedSeconds = _paywallShownTime != null
        ? DateTime.now().difference(_paywallShownTime!).inSeconds
        : null;
    _logEventUsecase.call(
      eventName: AnalyticsEvents.paywallDismissed,
      properties: {
        'time_viewed_seconds': timeViewedSeconds,
        'cta_tapped': ctaTapped,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
