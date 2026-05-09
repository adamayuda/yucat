import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';

/// Lifecycle-aware wrapper around `in_app_review`.
///
/// Apple shows the native review modal at most 3 times per 365 days per
/// user-account, regardless of how often we call it. This service adds a
/// thinner local gate so we don't burn the budget on low-intent moments:
///
/// - Only prompt after the user has had at least N successful scans.
/// - Don't prompt within `_minDaysBetweenPrompts` of the last attempt.
///
/// Trigger sites call `maybePrompt(trigger:)`; the service decides whether
/// to actually invoke the system modal.
class ReviewPromptService {
  static const String _scanCountKey = 'review_scan_count';
  static const String _lastPromptKey = 'review_last_prompt_at';
  static const int _minScansBeforeFirstPrompt = 5;
  static const int _minDaysBetweenPrompts = 90;

  final SharedPreferences _prefs;
  final LogEventUsecase _logEventUsecase;
  final InAppReview _inAppReview;

  ReviewPromptService({
    required SharedPreferences prefs,
    required LogEventUsecase logEventUsecase,
    InAppReview? inAppReview,
  })  : _prefs = prefs,
        _logEventUsecase = logEventUsecase,
        _inAppReview = inAppReview ?? InAppReview.instance;

  /// Records a successful scan. Bumps the gate counter.
  Future<void> recordScan() async {
    final count = _prefs.getInt(_scanCountKey) ?? 0;
    await _prefs.setInt(_scanCountKey, count + 1);
  }

  /// Considers showing the native review prompt at a high-intent moment.
  /// `trigger` is for analytics: e.g., 'post_paywall_success', 'nth_scan'.
  Future<void> maybePrompt({required String trigger}) async {
    if (!await _shouldPrompt()) return;

    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
        await _prefs.setInt(
          _lastPromptKey,
          DateTime.now().millisecondsSinceEpoch,
        );
        _logEventUsecase.call(
          eventName: 'Review Prompt Requested',
          properties: {
            'trigger': trigger,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }
    } catch (e) {
      debugPrint('ReviewPromptService.maybePrompt error: $e');
    }
  }

  Future<bool> _shouldPrompt() async {
    final scanCount = _prefs.getInt(_scanCountKey) ?? 0;
    if (scanCount < _minScansBeforeFirstPrompt) return false;

    final lastPromptMs = _prefs.getInt(_lastPromptKey);
    if (lastPromptMs != null) {
      final last = DateTime.fromMillisecondsSinceEpoch(lastPromptMs);
      final daysSince = DateTime.now().difference(last).inDays;
      if (daysSince < _minDaysBetweenPrompts) return false;
    }
    return true;
  }
}
