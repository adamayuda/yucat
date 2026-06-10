import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/services/user_analytics_service.dart';

/// Thin wrapper around the OneSignal SDK so the rest of the app never touches
/// it directly. iOS-only — push is not wired for Android (mirrors RevenueCat).
///
/// Lifecycle:
///  - [initialize] is called once at boot (after Firebase). It does NOT prompt
///    for permission — that is deferred to the onboarding reminders screen.
///  - [requestPermission] is called when the user taps the reminders-screen CTA.
///  - [login] attaches the anonymous Firebase UID as the OneSignal external id,
///    called once the user is guaranteed signed in (HomeBloc init).
class NotificationService {
  // OneSignal App ID — paste the value from the OneSignal dashboard
  // (Settings → Keys & IDs). Left inline to mirror the RevenueCat key in
  // main.dart.
  static const String _appId = '2a0ad1ef-59ab-43d5-bfef-b3670478287f';

  final LogEventUsecase _logEventUsecase;
  final UserAnalyticsService _userAnalyticsService;

  bool _initialized = false;

  NotificationService({
    required LogEventUsecase logEventUsecase,
    required UserAnalyticsService userAnalyticsService,
  })  : _logEventUsecase = logEventUsecase,
        _userAnalyticsService = userAnalyticsService;

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
