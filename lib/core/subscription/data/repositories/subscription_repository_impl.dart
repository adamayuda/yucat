import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:yucat/core/subscription/domain/entities/subscription_status.dart';
import 'package:yucat/core/subscription/domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  static const String _entitlementID = 'yucat pro';
  static const Duration _timeout = Duration(seconds: 5);

  CustomerInfo? _cachedCustomerInfo;

  SubscriptionRepositoryImpl() : _cachedCustomerInfo = null;

  @override
  Future<CustomerInfo?> getCustomerInfo({bool forceRefresh = false}) async {
    if (forceRefresh || _cachedCustomerInfo == null) {
      try {
        _cachedCustomerInfo =
            await Purchases.getCustomerInfo().timeout(_timeout);
      } catch (_) {
        return null;
      }
    }

    return _cachedCustomerInfo;
  }

  @override
  Future<bool> hasActiveSubscription({bool forceRefresh = false}) async =>
      (await getStatus(forceRefresh: forceRefresh)).isActive;

  @override
  Future<SubscriptionStatus> getStatus({bool forceRefresh = false}) async {
    final customerInfo = await getCustomerInfo(forceRefresh: forceRefresh);
    final entitlement = customerInfo?.entitlements.all[_entitlementID];
    if (entitlement == null || !entitlement.isActive) {
      return SubscriptionStatus.none;
    }
    return SubscriptionStatus(
      isActive: true,
      isTrial: entitlement.periodType == PeriodType.trial,
    );
  }

  /// RevenueCat runs on its own anonymous id until told otherwise. Logging in
  /// with the Firebase uid aliases that anonymous customer (and any purchase it
  /// made) into the uid, so a subscriber's RevenueCat record, Mixpanel profile
  /// and OneSignal user all share one key. The Mixpanel distinct id attribute
  /// is what lets RevenueCat's Mixpanel integration post trial/renewal/churn
  /// events onto the same profile the app writes to.
  ///
  /// Skips the network round-trip on every launch after the first, when the
  /// SDK already reports [uid] as the current app user.
  @override
  Future<void> linkUser(String uid) async {
    if (uid.isEmpty) return;
    try {
      if (await Purchases.appUserID != uid) {
        final result = await Purchases.logIn(uid).timeout(_timeout);
        _cachedCustomerInfo = result.customerInfo;
      }
      await Purchases.setMixpanelDistinctID(uid);
    } catch (e) {
      debugPrint('SubscriptionRepositoryImpl.linkUser error: $e');
    }
  }

  /// `logOut` throws when the SDK is already anonymous; that is the state we
  /// want, so it's swallowed like every other error here.
  @override
  Future<void> unlinkUser() async {
    _cachedCustomerInfo = null;
    try {
      await Purchases.logOut().timeout(_timeout);
    } catch (e) {
      debugPrint('SubscriptionRepositoryImpl.unlinkUser error: $e');
    }
  }
}
