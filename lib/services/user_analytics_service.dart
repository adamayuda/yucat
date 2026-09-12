import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/domain/usecase/identify_user_usecase.dart';
import 'package:yucat/features/analytics/domain/usecase/set_user_properties_usecase.dart';
import 'package:yucat/services/session_replay_service.dart';

/// Single place that owns Mixpanel People-profile identity and properties, so
/// property names live in one file and call sites stay one-liners.
///
/// All methods are fire-and-forget and swallow errors — analytics must never
/// break a user flow.
class UserAnalyticsService {
  final IdentifyUserUsecase _identifyUserUsecase;
  final SetUserPropertiesUsecase _setUserPropertiesUsecase;
  final SessionReplayService _sessionReplayService;

  bool _identified = false;

  UserAnalyticsService({
    required IdentifyUserUsecase identifyUserUsecase,
    required SetUserPropertiesUsecase setUserPropertiesUsecase,
    required SessionReplayService sessionReplayService,
  }) : _identifyUserUsecase = identifyUserUsecase,
       _setUserPropertiesUsecase = setUserPropertiesUsecase,
       _sessionReplayService = sessionReplayService;

  String get _platform =>
      Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : 'other');

  /// Bind events to a stable profile keyed by the anonymous Firebase UID.
  /// Idempotent per session; also stamps the platform once.
  ///
  /// Session Replay is a separate SDK with its own copy of the distinct id, so
  /// it has to be pointed at the same uid here — otherwise replays and events
  /// land on two different Mixpanel profiles.
  Future<void> identify(String uid) async {
    if (_identified || uid.isEmpty) return;
    _identified = true;
    try {
      await _identifyUserUsecase(uid);
      _sessionReplayService.identify(uid);
      final now = DateTime.now().toIso8601String();
      await _setUserPropertiesUsecase({
        UserProps.platform: _platform,
        // Refreshed every boot, which is what makes "no activity in 7 days"
        // segmentable. Recency previously lived only as a OneSignal tag.
        UserProps.lastActiveAt: now,
      });
      // `$created` must survive later launches, so it is the one property
      // written with set-once. A plain set here would reset first-seen to today
      // on every cold start and make cohort ageing meaningless.
      await _setUserPropertiesUsecase.setSingleOnce(UserProps.created, now);
      await _setUserPropertiesUsecase.increment(UserProps.totalSessions, 1);
    } catch (e) {
      _identified = false;
      debugPrint('UserAnalyticsService.identify error: $e');
    }
  }

  /// QA reset: allow the next [identify] to run again in this same process.
  /// The Mixpanel-side reset happens in `QaResetService`, which holds the
  /// repository; this only clears the per-session guard.
  void forgetIdentity() => _identified = false;

  /// App language and device country, stamped once the app has resolved its
  /// locale. Two properties, not one: [UserProps.language] is what the user
  /// reads (one of the six shipped locales, English for anything unsupported)
  /// while [UserProps.country] is the market. Nothing recorded either, so the
  /// six-locale investment was unmeasurable.
  Future<void> syncLocale({required String language, String? country}) async {
    try {
      await _setUserPropertiesUsecase({
        UserProps.language: language,
        if (country != null) UserProps.country: country,
      });
    } catch (e) {
      debugPrint('UserAnalyticsService.syncLocale error: $e');
    }
  }

  /// [isTrial] is passed wherever the entitlement was actually read (purchase
  /// success, every splash gate) so the profile flag tracks the store, not the
  /// paywall's eligibility guess. [trialStartedAt] is only ever passed on the
  /// purchase that opened the trial.
  Future<void> syncSubscription({
    required bool isSubscriber,
    bool? isTrial,
    DateTime? trialStartedAt,
    String? plan,
    double? price,
    String? currency,
  }) async {
    try {
      await _setUserPropertiesUsecase({
        UserProps.isSubscriber: isSubscriber,
        if (isTrial != null) UserProps.isTrial: isTrial,
        if (trialStartedAt != null)
          UserProps.trialStartedAt: trialStartedAt.toIso8601String(),
        if (plan != null) UserProps.subscriptionPlan: plan,
        if (price != null) UserProps.subscriptionPrice: price,
        if (currency != null) UserProps.subscriptionCurrency: currency,
      });
    } catch (e) {
      debugPrint('UserAnalyticsService.syncSubscription error: $e');
    }
  }

  Future<void> syncCats({
    required int count,
    String? primaryAgeGroup,
    String? primaryBreed,
  }) async {
    try {
      await _setUserPropertiesUsecase({
        UserProps.catsCount: count,
        UserProps.hasCat: count > 0,
        if (primaryAgeGroup != null)
          UserProps.primaryCatAgeGroup: primaryAgeGroup,
        // Breed drives ~25 rules in `cat_product_assessment.dart`; recording it
        // is how you find out whether real users own the breeds those rules
        // cover, or mostly ones that fall through to the archetypes.
        if (primaryBreed != null) UserProps.primaryCatBreed: primaryBreed,
      });
    } catch (e) {
      debugPrint('UserAnalyticsService.syncCats error: $e');
    }
  }

  /// Records a successful scan: bumps the lifetime counter and stamps the
  /// last-scan time. Counts both categories — a litter scan is a scan.
  Future<void> recordScan() async {
    try {
      await _setUserPropertiesUsecase.increment(UserProps.totalScans, 1);
      await _setUserPropertiesUsecase({
        UserProps.lastScanAt: DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('UserAnalyticsService.recordScan error: $e');
    }
  }

  Future<void> setAttribution(String source) async {
    try {
      await _setUserPropertiesUsecase.setSingle(
        UserProps.attributionSource,
        source,
      );
    } catch (e) {
      debugPrint('UserAnalyticsService.setAttribution error: $e');
    }
  }

  Future<void> markOnboardingComplete() async {
    try {
      await _setUserPropertiesUsecase({
        UserProps.onboardingCompleted: true,
        UserProps.onboardingCompletedAt: DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('UserAnalyticsService.markOnboardingComplete error: $e');
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      await _setUserPropertiesUsecase.setSingle(
        UserProps.notificationsEnabled,
        enabled,
      );
    } catch (e) {
      debugPrint('UserAnalyticsService.setNotificationsEnabled error: $e');
    }
  }
}
