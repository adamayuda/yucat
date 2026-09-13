import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/health_carnet/presentation/models/cat_health_summary.dart';
import 'package:yucat/features/health_carnet/presentation/models/health_due_item.dart';

/// The property bag for `Home Health Card Tapped` — the one "carnet door"
/// event, whatever surface the door is on.
///
/// The event keeps its historical name (Mixpanel board 11522118 breaks it
/// down by `state`; a rename would orphan that row) and gains `surface`, so
/// "which door converts" is one breakdown rather than four events. Every
/// surface must build its properties here, or the shapes drift.
abstract final class HealthEntrySurface {
  static const home = 'home';
  static const catDetail = 'cat_detail';
  static const catListing = 'cat_listing';
  static const profile = 'profile';
}

abstract final class HealthEntryState {
  /// A dated item is shown.
  static const due = 'due';

  /// The cat has no history; the surface invites setup.
  static const setup = 'setup';

  /// History exists and nothing is due inside the horizon.
  static const allClear = 'all_clear';

  /// The read failed, so the surface showed its neutral fallback.
  static const unknown = 'unknown';
}

/// [state] for a surface that renders from a [CatHealthSummary]. Null means
/// the read failed.
String healthEntryStateOf(CatHealthSummary? summary) {
  if (summary == null) return HealthEntryState.unknown;
  if (!summary.hasHistory) return HealthEntryState.setup;
  if (summary.nearest != null) return HealthEntryState.due;
  return HealthEntryState.allClear;
}

/// [extra] carries surface-specific counts (`others_due_count` on Home,
/// `cats_count` / `due_soon_count` on Profile) without each surface growing
/// its own property map.
Map<String, Object?> healthEntryTapProperties({
  required String surface,
  required String state,
  required CatEntity cat,
  HealthDueItem? item,
  Map<String, Object?> extra = const {},
}) {
  return {
    'surface': surface,
    'state': state,
    if (item != null) ...{
      'protocol_id': item.protocol.id,
      'urgency': item.urgency.wire,
      'days_until': item.daysUntil ?? 0,
    },
    ...extra,
    'cat_id': cat.id,
    'timestamp': DateTime.now().toIso8601String(),
  };
}
