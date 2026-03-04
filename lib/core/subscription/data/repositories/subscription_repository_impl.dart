import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:yucat/core/subscription/domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  static const String _entitlementID = 'yucat pro';

  CustomerInfo? _cachedCustomerInfo;

  SubscriptionRepositoryImpl() : _cachedCustomerInfo = null;

  @override
  Future<CustomerInfo?> getCustomerInfo({bool forceRefresh = false}) async {
    if (forceRefresh || _cachedCustomerInfo == null) {
      _cachedCustomerInfo = await Purchases.getCustomerInfo();
    }

    return _cachedCustomerInfo;
  }

  @override
  Future<bool> hasActiveSubscription({bool forceRefresh = false}) async {
    final customerInfo = await getCustomerInfo(forceRefresh: forceRefresh);

    if (customerInfo == null) {
      return false;
    }

    final entitlement = customerInfo.entitlements.all[_entitlementID];
    return entitlement?.isActive == true;
  }
}
