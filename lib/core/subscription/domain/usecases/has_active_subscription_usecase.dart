import 'package:yucat/core/subscription/domain/repositories/subscription_repository.dart';

class HasActiveSubscriptionUseCase {
  final SubscriptionRepository _repository;

  HasActiveSubscriptionUseCase({required SubscriptionRepository repository})
    : _repository = repository;

  Future<bool> call({bool forceRefresh = false}) async {
    return await _repository.hasActiveSubscription(forceRefresh: forceRefresh);
  }
}
