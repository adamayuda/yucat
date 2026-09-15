import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/analytics/analytics_events.dart';

/// Where a review prompt was attempted from — the `trigger` property on
/// `Review Prompt Requested`, so Mixpanel can tell which moment earns reviews.
abstract final class ReviewTrigger {
  /// Back on Home after reading a scan result that carried real data.
  static const postScan = 'post_scan';
  static const productSaved = 'product_saved';
  static const litterSaved = 'litter_saved';
  static const healthSetupCompleted = 'health_setup_completed';
  static const healthBookletImported = 'health_booklet_imported';
}

/// Lifecycle-aware wrapper around `in_app_review`.
///
/// Apple shows the native review modal at most 3 times per 365 days per
/// user-account, regardless of how often we call it. This service adds a
/// thinner local gate so we don't burn the budget on low-intent moments:
///
/// - Only prompt after the user has had at least N **positive moments** — a
///   scan result with data, a save, a completed carnet setup or booklet
///   import. Scans alone used to be the only signal, at 5: two thirds of
///   scanners never got that far.
/// - Don't prompt within `_minDaysBetweenPrompts` of the last attempt.
///
/// Trigger sites call `recordPositiveMoment(trigger:)`, which counts the moment
/// and then decides whether to actually invoke the system modal.
class ReviewPromptService {
  // Historical name: the counter predates the non-scan moments. Kept so the
  // scans users already have keep counting toward the gate.
  static const String _momentCountKey = 'review_scan_count';
  static const String _lastPromptKey = 'review_last_prompt_at';
  static const int _minMomentsBeforeFirstPrompt = 2;
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

  /// Counts one positive moment, then considers showing the native review
  /// prompt. `trigger` is a [ReviewTrigger] value, for analytics.
  ///
  /// Call it only once the user has *seen* the value — never before the
  /// result screen is on top, or the modal lands on a transition.
  Future<void> recordPositiveMoment({required String trigger}) async {
    final count = _prefs.getInt(_momentCountKey) ?? 0;
    await _prefs.setInt(_momentCountKey, count + 1);
    await _maybePrompt(trigger: trigger);
  }

  Future<void> _maybePrompt({required String trigger}) async {
    if (!_shouldPrompt()) return;

    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
        await _prefs.setInt(
          _lastPromptKey,
          DateTime.now().millisecondsSinceEpoch,
        );
        _logEventUsecase.call(
          eventName: AnalyticsEvents.reviewPromptRequested,
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

  bool _shouldPrompt() {
    final count = _prefs.getInt(_momentCountKey) ?? 0;
    if (count < _minMomentsBeforeFirstPrompt) return false;

    final lastPromptMs = _prefs.getInt(_lastPromptKey);
    if (lastPromptMs != null) {
      final last = DateTime.fromMillisecondsSinceEpoch(lastPromptMs);
      final daysSince = DateTime.now().difference(last).inDays;
      if (daysSince < _minDaysBetweenPrompts) return false;
    }
    return true;
  }
}
