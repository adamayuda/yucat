import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/services/user_analytics_service.dart';

/// How far through the acquisition funnel a user has got.
///
/// The ordinal is the ranking used by [NotificationService.setFunnelStage] to
/// keep the `funnel_stage` tag monotonic, so **order matters** — append only.
enum FunnelStage {
  onboarding,
  catCreate,
  paywall,
  subscribed;

  /// The literal written to OneSignal. Kept explicit rather than derived from
  /// [name] so a Dart rename can't silently invalidate a dashboard Segment.
  String get tagValue => switch (this) {
        FunnelStage.onboarding => 'onboarding',
        FunnelStage.catCreate => 'cat_create',
        FunnelStage.paywall => 'paywall',
        FunnelStage.subscribed => 'subscribed',
      };
}

/// OneSignal tag keys. Values are always strings — OneSignal has no typed tags,
/// and dashboard Segments compare them as strings.
class NotificationTags {
  NotificationTags._();

  static const funnelStage = 'funnel_stage';
  static const onboardingCompleted = 'onboarding_completed';
  static const hasCat = 'has_cat';
  static const paywallSeen = 'paywall_seen';
  static const isSubscriber = 'is_subscriber';
  static const lastActiveAt = 'last_active_at';

  /// OneSignal has no booleans; these are the only two values a bool tag takes.
  static String boolValue(bool v) => v ? 'true' : 'false';
}

/// Thin wrapper around the OneSignal SDK so the rest of the app never touches
/// it directly. iOS-only — push is not wired for Android (mirrors RevenueCat).
///
/// Lifecycle:
///  - [initialize] is called once at boot (after Firebase). It does NOT prompt
///    for permission — that is deferred to the onboarding reminders screen.
///  - [requestPermission] is called when the user taps the reminders-screen CTA.
///  - [login] attaches the anonymous Firebase UID as the OneSignal external id,
///    called from SplashBloc once sign-in has been awaited — early, so tags
///    written during the funnel land on an identified user rather than an
///    anonymous device record.
///
/// See `docs/onesignal.md` for the tag schema and the Segments it enables.
class NotificationService {
  // OneSignal App ID — paste the value from the OneSignal dashboard
  // (Settings → Keys & IDs). Left inline to mirror the RevenueCat key in
  // main.dart.
  static const String _appId = '2a0ad1ef-59ab-43d5-bfef-b3670478287f';

  /// Highest [FunnelStage] index ever reached, persisted so the tag can't
  /// regress across app launches.
  static const String _furthestStageKey = 'onesignal_furthest_funnel_stage';

  final LogEventUsecase _logEventUsecase;
  final UserAnalyticsService _userAnalyticsService;
  final SharedPreferences _prefs;

  bool _initialized = false;

  NotificationService({
    required LogEventUsecase logEventUsecase,
    required UserAnalyticsService userAnalyticsService,
    required SharedPreferences prefs,
  })  : _logEventUsecase = logEventUsecase,
        _userAnalyticsService = userAnalyticsService,
        _prefs = prefs;

  /// Initialise the SDK. No-op on non-iOS platforms. Safe to call more than
  /// once.
  Future<void> initialize() async {
    if (!Platform.isIOS || _initialized) return;

    if (kDebugMode) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    }
    OneSignal.initialize(_appId);
    _initialized = true;
  }

  /// Prompt the OS notification permission dialog. Returns whether permission
  /// was granted. Safe to await — never throws to the caller.
  Future<bool> requestPermission() async {
    if (!Platform.isIOS) return false;

    bool granted = false;
    try {
      granted = await OneSignal.Notifications.requestPermission(true);
    } catch (e) {
      debugPrint('OneSignal requestPermission error: $e');
    }

    _logEventUsecase.call(
      eventName: granted ? 'Notifications Opted In' : 'Notifications Opted Out',
      properties: {
        'source': 'onboarding_reminders',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    _userAnalyticsService.setNotificationsEnabled(granted);

    return granted;
  }

  /// Attach the anonymous Firebase UID as the OneSignal external id so the
  /// device stays identified across reinstalls. No-op if not initialised.
  Future<void> login(String uid) async {
    if (!Platform.isIOS || !_initialized || uid.isEmpty) return;
    try {
      await OneSignal.login(uid);
    } catch (e) {
      debugPrint('OneSignal login error: $e');
    }
  }

  /// Write OneSignal tags for dashboard segmentation.
  ///
  /// Fire-and-forget: no-op off iOS or before [initialize], and never throws —
  /// tagging must not be able to break a user flow.
  Future<void> setTags(Map<String, String> tags) async {
    if (!Platform.isIOS || !_initialized || tags.isEmpty) return;
    try {
      await OneSignal.User.addTags(tags);
    } catch (e) {
      debugPrint('OneSignal setTags error: $e');
    }
  }

  /// Record the furthest funnel stage this user has reached.
  ///
  /// Monotonic: a call with a stage at or below the high-water mark is ignored,
  /// so re-entering onboarding (debug reset, or a returning user routed through
  /// the splash gate) can't demote a subscriber back to `onboarding` and quietly
  /// drop them into a win-back segment.
  ///
  /// The high-water mark is persisted rather than held in memory — the service
  /// is a singleton, but the process dies between sessions.
  Future<void> setFunnelStage(FunnelStage stage) async {
    if (!Platform.isIOS || !_initialized) return;

    final furthest = _prefs.getInt(_furthestStageKey) ?? -1;
    if (stage.index <= furthest) return;

    try {
      await _prefs.setInt(_furthestStageKey, stage.index);
    } catch (e) {
      debugPrint('OneSignal setFunnelStage persist error: $e');
    }
    await setTags({NotificationTags.funnelStage: stage.tagValue});
  }

  /// Mirror subscription state onto the user record.
  ///
  /// Must be called on **every** splash gate, not only on purchase — otherwise a
  /// churned subscriber keeps `is_subscriber = true` for ever and silently falls
  /// out of every win-back segment.
  Future<void> setSubscriber(bool isSubscriber) => setTags({
        NotificationTags.isSubscriber: NotificationTags.boolValue(isSubscriber),
      });

  /// Stamp today's date, for "dormant for N days" segments.
  ///
  /// Date-only on purpose: it changes at most once a day, which keeps tag writes
  /// cheap and is the right resolution for a recency segment.
  Future<void> setLastActive() {
    final today = DateTime.now().toIso8601String().split('T').first;
    return setTags({NotificationTags.lastActiveAt: today});
  }

  /// Detach the external id. Kept for completeness; unused while auth is
  /// anonymous-only.
  Future<void> logout() async {
    if (!Platform.isIOS || !_initialized) return;
    try {
      await OneSignal.logout();
    } catch (e) {
      debugPrint('OneSignal logout error: $e');
    }
  }
}
