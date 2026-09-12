import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/core/subscription/domain/repositories/subscription_repository.dart';
import 'package:yucat/features/analytics/domain/repository/analytics_repository.dart';
import 'package:yucat/features/auth/domain/repository/auth_repository.dart';
import 'package:yucat/services/notification_service.dart';
import 'package:yucat/services/user_analytics_service.dart';

/// "Reset test user" — makes the next launch a genuinely new user.
///
/// Deleting the app is not enough on iOS: the anonymous Firebase session lives
/// in the Keychain and survives an uninstall, so a reinstall comes back as the
/// same uid, the same RevenueCat customer (with whatever sandbox subscription
/// it holds) and the same Mixpanel profile. That made every paywall test after
/// the first one fight yesterday's entitlement.
///
/// Order matters: RevenueCat is detached *before* Firebase signs out so the
/// log-out runs against the identified customer, and prefs are cleared last
/// so a failure earlier leaves the app consistent. Every step swallows its own
/// errors — this is a QA tool, and a half-reset is still more useful than a
/// crash. Reachable only behind `kQaToolsEnabled`.
class QaResetService {
  final AuthRepository _auth;
  final SubscriptionRepository _subscription;
  final AnalyticsRepository _analytics;
  final UserAnalyticsService _userAnalytics;
  final NotificationService _notifications;
  final SharedPreferences _prefs;

  QaResetService({
    required AuthRepository auth,
    required SubscriptionRepository subscription,
    required AnalyticsRepository analytics,
    required UserAnalyticsService userAnalytics,
    required NotificationService notifications,
    required SharedPreferences prefs,
  })  : _auth = auth,
        _subscription = subscription,
        _analytics = analytics,
        _userAnalytics = userAnalytics,
        _notifications = notifications,
        _prefs = prefs;

  Future<void> resetTestUser() async {
    await _subscription.unlinkUser();
    await _notifications.logout();
    try {
      await _analytics.reset();
    } catch (e) {
      debugPrint('QaResetService analytics reset error: $e');
    }
    _userAnalytics.forgetIdentity();
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('QaResetService signOut error: $e');
    }
    // Onboarding flag, saved/history stores, review-prompt counters, the
    // OneSignal funnel high-water mark — all keyed to the old user.
    await _prefs.clear();
  }
}
