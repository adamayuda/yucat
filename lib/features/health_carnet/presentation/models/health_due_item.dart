import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_protocol.dart';

/// How loudly a due item should present itself.
///
/// [toSchedule] is the one that earns its keep: a protocol the cat has **no
/// record of** whose earliest-eligible date is already past. Rendering that as
/// "overdue by 8 months" would be alarming and, given the birth date is
/// approximated from a profile age that never ages, frequently wrong. It reads
/// "to schedule" instead — an invitation, not an alarm.
enum HealthUrgency {
  overdue,
  urgent,
  soon,
  later,
  toSchedule;

  /// Sort rank. Alarming items first, suggestions last — so a stale profile's
  /// unrecorded protocols can never crowd out a genuinely late booster.
  int get rank => index;

  /// Counts toward the "dont N urgent" figure on the summary tile.
  bool get isPressing =>
      this == HealthUrgency.overdue || this == HealthUrgency.urgent;
}

/// One computed line in the "À venir" list.
///
/// Never persisted. The schedule is a pure function of history + profile, so a
/// due item exists only for as long as it takes to render — which is what stops
/// it from drifting out of sync with the records it was derived from.
class HealthDueItem {
  final HealthProtocol protocol;

  /// Null only when the profile carries no age at all, so nothing can be dated.
  final DateTime? dueDate;

  final HealthUrgency urgency;

  /// The record this was computed from, if any. Null means [HealthUrgency.toSchedule].
  final HealthEventEntity? lastDone;

  /// The recurrence that applied, in days — the "Tous les 3 mois" line. Null for
  /// a one-time act.
  final int? intervalDays;

  /// True while the cat is mid kitten-series (FVRCP at 3-weekly intervals),
  /// which the copy calls out so an owner doesn't read it as an annual booster.
  final bool isSeriesDose;

  /// Whole days from now. Negative when overdue.
  final int? daysUntil;

  const HealthDueItem({
    required this.protocol,
    required this.dueDate,
    required this.urgency,
    this.lastDone,
    this.intervalDays,
    this.isSeriesDose = false,
    this.daysUntil,
  });

  bool get isRecurring => intervalDays != null;
}
