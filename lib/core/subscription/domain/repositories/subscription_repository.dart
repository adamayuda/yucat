import 'package:purchases_flutter/models/customer_info_wrapper.dart';

abstract class SubscriptionRepository {
  Future<CustomerInfo?> getCustomerInfo({bool forceRefresh = false});
  Future<bool> hasActiveSubscription({bool forceRefresh = false});
}
