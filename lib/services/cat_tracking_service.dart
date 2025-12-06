import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:yucat/features/cat/domain/usecases/get_cats_usecase.dart';

class CatTrackingService {
  static const String _entitlementID = 'yucat Pro';
  static const int _maxFreeCats = 1;

  final GetCatsUsecase _getCatsUsecase;

  CatTrackingService({required GetCatsUsecase getCatsUsecase})
      : _getCatsUsecase = getCatsUsecase;

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

  /// Get the current number of cats for a user
  Future<int> getCatsCount({required String userId}) async {
    try {
      final cats = await _getCatsUsecase(userId: userId);
      return cats.length;
    } catch (e) {
      // If there's an error, assume 0 cats
      return 0;
    }
  }

  /// Check if user has reached the free cat limit
  Future<bool> hasReachedFreeCatLimit({required String userId}) async {
    final catsCount = await getCatsCount(userId: userId);
    return catsCount >= _maxFreeCats;
  }

  /// Check if user can create a cat (has subscription or hasn't reached limit)
  Future<bool> canCreateCat({required String userId}) async {
    final hasSubscription = await hasActiveSubscription();
    if (hasSubscription) {
      return true;
    }
    return !(await hasReachedFreeCatLimit(userId: userId));
  }
}

