import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/core/subscription/domain/usecases/has_active_subscription_usecase.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';

class ScanTrackingService {
  static const String _freeScansCountKey = 'free_scans_count';
  static const String _streakLastScanDateKey = 'streak_last_scan_date';
  static const String _streakCurrentKey = 'streak_current';
  static const String _streakLongestKey = 'streak_longest';
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

  // -- Scan streak --

  /// Current streak length in days. 0 if user hasn't scanned today and the
  /// previous streak (if any) is broken.
  int getCurrentStreak() {
    final stored = _prefs.getInt(_streakCurrentKey) ?? 0;
    if (stored == 0) return 0;
    final last = _readLastScanDate();
    if (last == null) return 0;
    final today = _today();
    final daysSince = today.difference(last).inDays;
    if (daysSince <= 1) return stored; // today or yesterday — still alive
    return 0; // streak has expired
  }

  /// Longest streak ever achieved.
  int getLongestStreak() => _prefs.getInt(_streakLongestKey) ?? 0;

  /// Records a successful scan and advances/resets the streak. Returns the
  /// new current streak length so callers can react (e.g., milestone toast).
  Future<int> recordSuccessfulScan() async {
    final today = _today();
    final last = _readLastScanDate();
    final stored = _prefs.getInt(_streakCurrentKey) ?? 0;

    int next;
    if (last == null) {
      next = 1;
    } else {
      final daysSince = today.difference(last).inDays;
      if (daysSince == 0) {
        next = stored == 0 ? 1 : stored; // already counted today
      } else if (daysSince == 1) {
        next = stored + 1; // consecutive day
      } else {
        next = 1; // gap broke the streak
      }
    }

    await _prefs.setInt(_streakCurrentKey, next);
    await _prefs.setString(_streakLastScanDateKey, _formatDate(today));

    final longest = getLongestStreak();
    if (next > longest) {
      await _prefs.setInt(_streakLongestKey, next);
      _logEventUsecase.call(
        eventName: 'Streak Milestone',
        properties: {
          'streak_days': next,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
    return next;
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime? _readLastScanDate() {
    final raw = _prefs.getString(_streakLastScanDateKey);
    if (raw == null) return null;
    final parts = raw.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
