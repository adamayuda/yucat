import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/core/subscription/domain/usecases/has_active_subscription_usecase.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';

/// Free-tier scan gating.
///
/// ⚠️ **Nothing calls this today.** The app is a hard paywall (see
/// `lib/features/paywall/README.md`), so every gating method below is dormant;
/// the class is kept intact so a free tier can be re-enabled without rewriting
/// it. It previously also tracked a daily scan streak, which was removed
/// because no screen ever rendered it — see `docs/analytics.md`.
class ScanTrackingService {
  static const String _freeScansCountKey = 'free_scans_count';
  static const int _maxFreeScans = 3;

  /// Maximum free-tier scans allowed before paywall.
  int get maxFreeScans => _maxFreeScans;

  /// Remaining free scans (clamped to 0). Pure read — does not increment.
  int getRemainingScans() {
    final used = getFreeScansCount();
    final remaining = _maxFreeScans - used;
    return remaining < 0 ? 0 : remaining;
  }

  final SharedPreferences _prefs;
  final HasActiveSubscriptionUseCase _hasActiveSubscriptionUseCase;
  final LogEventUsecase _logEventUsecase;

  ScanTrackingService({
    required SharedPreferences prefs,
    required HasActiveSubscriptionUseCase hasActiveSubscriptionUseCase,
    required LogEventUsecase logEventUsecase,
  }) : _prefs = prefs,
       _hasActiveSubscriptionUseCase = hasActiveSubscriptionUseCase,
       _logEventUsecase = logEventUsecase;

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
  Future<bool> hasReachedFreeScanLimit() async {
    final currentCount = getFreeScansCount();
    final hasReachedLimit = currentCount >= _maxFreeScans;
    if (!hasReachedLimit) {
      await incrementFreeScansCount();
    } else {
      // Track that user hit the limit
      _logEventUsecase.call(
        eventName: 'Free Limit Hit',
        properties: {
          'limit_type': 'scans',
          'limit_value': _maxFreeScans,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
    return hasReachedLimit;
  }

  /// Check if user can perform a scan (has subscription or hasn't reached limit)
  Future<bool> canPerformScan() async {
    final hasSubscription = await _hasActiveSubscriptionUseCase();
    if (hasSubscription) {
      return true;
    }

    final hasReachedLimit = await hasReachedFreeScanLimit();
    return !hasReachedLimit;
  }

  /// Reset the free scan count (useful for testing or if user purchases subscription)
  Future<void> resetFreeScansCount() async {
    await _prefs.remove(_freeScansCountKey);
  }
}
