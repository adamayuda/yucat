import 'package:flutter/services.dart';

/// Centralized haptic feedback so intensity is tuned in one place.
class DSHaptics {
  /// Light tick for selecting an option from a list/grid/chip set.
  static void selection() => HapticFeedback.selectionClick();

  /// Soft tap for primary CTAs (Next / Continue / Save).
  static void tap() => HapticFeedback.lightImpact();
}
