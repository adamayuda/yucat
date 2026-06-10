import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/domain/usecase/identify_user_usecase.dart';
import 'package:yucat/features/analytics/domain/usecase/set_user_properties_usecase.dart';

/// Single place that owns Mixpanel People-profile identity and properties, so
/// property names live in one file and call sites stay one-liners.
///
/// All methods are fire-and-forget and swallow errors — analytics must never
/// break a user flow.
class UserAnalyticsService {
  final IdentifyUserUsecase _identifyUserUsecase;
  final SetUserPropertiesUsecase _setUserPropertiesUsecase;

  bool _identified = false;

  UserAnalyticsService({
    required IdentifyUserUsecase identifyUserUsecase,
    required SetUserPropertiesUsecase setUserPropertiesUsecase,
  })  : _identifyUserUsecase = identifyUserUsecase,
        _setUserPropertiesUsecase = setUserPropertiesUsecase;

  String get _platform =>
      Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : 'other');

  /// Bind events to a stable profile keyed by the anonymous Firebase UID.
  /// Idempotent per session; also stamps the platform once.
  Future<void> identify(String uid) async {
    if (_identified || uid.isEmpty) return;
    _identified = true;
    try {
      await _identifyUserUsecase(uid);
      await _setUserPropertiesUsecase({UserProps.platform: _platform});
    } catch (e) {
      _identified = false;
      debugPrint('UserAnalyticsService.identify error: $e');
    }
  }

  Future<void> syncSubscription({
    required bool isSubscriber,
    String? plan,
    double? price,
    String? currency,
  }) async {
    try {
      await _setUserPropertiesUsecase({
        UserProps.isSubscriber: isSubscriber,
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
  }) async {
    try {
      await _setUserPropertiesUsecase({
        UserProps.catsCount: count,
        UserProps.hasCat: count > 0,
        if (primaryAgeGroup != null)
          UserProps.primaryCatAgeGroup: primaryAgeGroup,
      });
    } catch (e) {
      debugPrint('UserAnalyticsService.syncCats error: $e');
    }
  }

  /// Records a successful scan: bumps the lifetime counter and stamps the
  /// streak + last-scan time.
  Future<void> recordScan({required int currentStreak}) async {
    try {
      await _setUserPropertiesUsecase.increment(UserProps.totalScans, 1);
      await _setUserPropertiesUsecase({
        UserProps.currentStreak: currentStreak,
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
