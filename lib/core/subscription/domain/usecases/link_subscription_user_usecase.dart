import 'package:yucat/core/subscription/domain/repositories/subscription_repository.dart';

/// Ties the store-side subscription identity to the app's own user id so
/// purchase events and profiles can be joined across RevenueCat, Mixpanel and
/// OneSignal. Idempotent; never throws.
class LinkSubscriptionUserUsecase {
  final SubscriptionRepository _repository;

  LinkSubscriptionUserUsecase({required SubscriptionRepository repository})
    : _repository = repository;

  Future<void> call(String uid) => _repository.linkUser(uid);
}
