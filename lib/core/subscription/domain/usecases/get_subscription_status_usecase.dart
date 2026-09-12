import 'package:yucat/core/subscription/domain/entities/subscription_status.dart';
import 'package:yucat/core/subscription/domain/repositories/subscription_repository.dart';

class GetSubscriptionStatusUseCase {
  final SubscriptionRepository _repository;

  GetSubscriptionStatusUseCase({required SubscriptionRepository repository})
    : _repository = repository;

  Future<SubscriptionStatus> call({bool forceRefresh = false}) =>
      _repository.getStatus(forceRefresh: forceRefresh);
}
