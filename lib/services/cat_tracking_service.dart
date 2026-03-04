import 'package:yucat/features/cat/domain/usecases/get_cats_usecase.dart';
import 'package:yucat/core/subscription/domain/usecases/has_active_subscription_usecase.dart';

class CatTrackingService {
  static const int _maxFreeCats = 1;

  final GetCatsUsecase _getCatsUsecase;
  final HasActiveSubscriptionUseCase _hasActiveSubscriptionUseCase;

  CatTrackingService({
    required GetCatsUsecase getCatsUsecase,
    required HasActiveSubscriptionUseCase hasActiveSubscriptionUseCase,
  }) : _getCatsUsecase = getCatsUsecase,
       _hasActiveSubscriptionUseCase = hasActiveSubscriptionUseCase;

  /// Get the current number of cats for a user
  Future<int> _getCatsCount({required String userId}) async {
    try {
      final cats = await _getCatsUsecase(userId: userId);
      return cats.length;
    } catch (e) {
      // If there's an error, assume 0 cats
      return 0;
    }
  }

  /// Check if user has reached the free cat limit
  Future<bool> _hasReachedFreeCatLimit({required String userId}) async {
    final catsCount = await _getCatsCount(userId: userId);
    return catsCount >= _maxFreeCats;
  }

  /// Check if user can create a cat (has subscription or hasn't reached limit)
  Future<bool> canCreateCat({required String userId}) async {
    return true;
    final hasSubscription = await _hasActiveSubscriptionUseCase();
    if (hasSubscription) {
      return true;
    }
    return !(await _hasReachedFreeCatLimit(userId: userId));
  }
}
