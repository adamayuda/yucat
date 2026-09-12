import 'package:purchases_flutter/models/customer_info_wrapper.dart';
import 'package:yucat/core/subscription/domain/entities/subscription_status.dart';

abstract class SubscriptionRepository {
  Future<CustomerInfo?> getCustomerInfo({bool forceRefresh = false});
  Future<bool> hasActiveSubscription({bool forceRefresh = false});

  /// Active + trial state of the entitlement in one read.
  Future<SubscriptionStatus> getStatus({bool forceRefresh = false});

  /// Bind the store-side customer to [uid]. Safe to call on every launch.
  Future<void> linkUser(String uid);

  /// Detach the store-side customer so the next [linkUser] starts from a fresh
  /// anonymous customer with no purchase history. QA only.
  Future<void> unlinkUser();
}
