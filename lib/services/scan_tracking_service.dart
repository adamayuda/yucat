import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanTrackingService {
  static const String _freeScansCountKey = 'free_scans_count';
  static const String _entitlementID = 'yucat Pro';
  static const int _maxFreeScans = 3;

  final SharedPreferences _prefs;

  ScanTrackingService({required SharedPreferences prefs}) : _prefs = prefs;

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
  bool hasReachedFreeScanLimit() {
    return getFreeScansCount() >= _maxFreeScans;
  }

  /// Check if user has an active subscription
  Future<bool> hasActiveSubscription() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.all[_entitlementID];
      return entitlement?.isActive == true;
    } catch (e) {
      // If there's an error checking subscription, assume no subscription
      return false;
    }
  }

  /// Check if user can perform a scan (has subscription or hasn't reached limit)
  Future<bool> canPerformScan() async {
    final hasSubscription = await hasActiveSubscription();
    if (hasSubscription) {
      return true;
    }
    return !hasReachedFreeScanLimit();
  }

  /// Reset the free scan count (useful for testing or if user purchases subscription)
  Future<void> resetFreeScansCount() async {
    await _prefs.remove(_freeScansCountKey);
  }
}
