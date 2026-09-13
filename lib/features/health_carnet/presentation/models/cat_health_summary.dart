import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';
import 'package:yucat/features/health_carnet/presentation/models/health_due_item.dart';
import 'package:yucat/features/health_carnet/presentation/utils/cat_health_schedule.dart';

/// One cat's carnet, reduced to what a surface *outside* the carnet needs:
/// Home's next-up card, the Cat Detail row, the cat-list pill, Profile's
/// health row. Built by `summarizeCatHealth`; never persisted.
///
/// Everything here is derived from [events] + the profile, so it can never
/// disagree with the carnet page — which derives the same schedule from the
/// same records via `computeDueItems`.
class CatHealthSummary {
  final CatEntity cat;

  /// Every record, as read — `done` and `snoozed` alike.
  final List<HealthEventEntity> events;

  /// Derived, most pressing first. See `computeDueItems`.
  final List<HealthDueItem> dueItems;

  /// The nearest *dated* item, or null. Never `toSchedule` — those carry a
  /// placeholder date, not a deadline.
  final HealthDueItem? nearest;

  /// When [nearest] is null and the carnet has history: the first dated act
  /// beyond the 12-month horizon (a triennial FVRCP, a senior panel), so an
  /// all-clear surface can say what comes next instead of nothing. Null
  /// otherwise — it is only computed for a quiet carnet.
  final HealthDueItem? nextBeyondHorizon;

  const CatHealthSummary({
    required this.cat,
    required this.events,
    required this.dueItems,
    required this.nearest,
    this.nextBeyondHorizon,
  });

  /// At least one act has been recorded. `snoozed` rows do not count: they
  /// are scheduling residue, and a carnet holding only a snooze is still a
  /// carnet nobody has set up.
  bool get hasHistory => events.any((e) => e.isDone);

  /// Acts that happened — the timeline's length.
  int get recordCount => events.where((e) => e.isDone).length;

  /// The most recent weighing on any record, in kg.
  double? get latestWeightKg {
    final series = weightSeries(events.where((e) => e.isDone).toList());
    return series.isEmpty ? null : series.last.kg;
  }

  /// Overdue or due within a week.
  int get pressingCount => dueItems.where((d) => d.urgency.isPressing).length;

  /// Overdue, urgent or due within a month — the figure a badge should show.
  /// `later` items are real but not actionable today; `toSchedule` rows are
  /// gaps, not deadlines.
  int get dueSoonCount => dueItems
      .where((d) =>
          d.urgency == HealthUrgency.overdue ||
          d.urgency == HealthUrgency.urgent ||
          d.urgency == HealthUrgency.soon)
      .length;
}
