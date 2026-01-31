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
  bool hasReachedFreeScanLimit() {
    return getFreeScansCount() >= _maxFreeScans;
  }

  // /// Check if user has an active subscription
  // Future<bool> hasActiveSubscription() async {
  //   try {
  //     // Sync purchases first to ensure we have the latest subscription status
  //     await Purchases.syncPurchases();
  //     final customerInfo = await Purchases.getCustomerInfo();

  //     // Debug: Print all available entitlements
  //     debugPrint(
  //       'Available entitlements: ${customerInfo.entitlements.all.keys}',
  //     );
  //     debugPrint('Looking for entitlement: $_entitlementID');

  //     final entitlement = customerInfo.entitlements.all[_entitlementID];
  //     final isActive = entitlement?.isActive == true;

  //     debugPrint(
  //       'Entitlement found: ${entitlement != null}, isActive: $isActive',
  //     );

  //     return isActive;
  //   } catch (e) {
  //     debugPrint('Error checking subscription: $e');
  //     // If there's an error checking subscription, assume no subscription
  //     return false;
  //   }
  // }

  /// Check if user can perform a scan (has subscription or hasn't reached limit)
  Future<bool> canPerformScan() async {
    final hasSubscription = await _hasActiveSubscriptionUseCase();
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
