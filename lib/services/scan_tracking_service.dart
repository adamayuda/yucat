import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/core/subscription/domain/usecases/has_active_subscription_usecase.dart';

class ScanTrackingService {
  static const String _freeScansCountKey = 'free_scans_count';
  // static const String _entitlementID = 'yucat pro';
  static const int _maxFreeScans = 3;

  final SharedPreferences _prefs;
  final HasActiveSubscriptionUseCase _hasActiveSubscriptionUseCase;

  ScanTrackingService({
    required SharedPreferences prefs,
    required HasActiveSubscriptionUseCase hasActiveSubscriptionUseCase,
  }) : _prefs = prefs,
       _hasActiveSubscriptionUseCase = hasActiveSubscriptionUseCase;

  /// Get the current number of free scans used
  int getFreeScansCount() {
    return _prefs.getInt(_freeScansCountKey) ?? 0;
  }

  /// Increment the free scan count
  Future<void> incrementFreeScansCount() async {
    final currentCount = getFreeScansCount();
    await _prefs.setInt(_freeScansCountKey, currentCount + 1);
  }

  /// Check if user has reached the free scan limit
  Future<bool> hasReachedFreeScanLimit() async {
    final currentCount = getFreeScansCount();
    final hasReachedLimit = currentCount >= _maxFreeScans;
    if (!hasReachedLimit) {
      await incrementFreeScansCount();
    }
    return hasReachedLimit;
  }

  /// Check if user can perform a scan (has subscription or hasn't reached limit)
  Future<bool> canPerformScan() async {
    print('[ScanTrackingService] canPerformScan() called');
    final hasSubscription = await _hasActiveSubscriptionUseCase();
    print('[ScanTrackingService] hasSubscription: $hasSubscription');

    if (hasSubscription) {
      print(
        '[ScanTrackingService] User has active subscription, allowing scan',
      );
      return true;
    }

    final currentCount = getFreeScansCount();
    print(
      '[ScanTrackingService] Free scans used: $currentCount/$_maxFreeScans',
    );
    final hasReachedLimit = await hasReachedFreeScanLimit();
    print('[ScanTrackingService] hasReachedFreeScanLimit: $hasReachedLimit');
    final canScan = !hasReachedLimit;
    print('[ScanTrackingService] canPerformScan result: $canScan');
    return canScan;
  }

  /// Reset the free scan count (useful for testing or if user purchases subscription)
  Future<void> resetFreeScansCount() async {
    await _prefs.remove(_freeScansCountKey);
  }
}
