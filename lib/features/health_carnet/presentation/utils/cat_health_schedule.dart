/// The schedule engine: what this cat is due for, and when.
///
/// Same shape as `cat_diet_recommendations.dart` — a pure top-level function in
/// `presentation/utils/`, no DI, no I/O, no state.
///
/// Two deliberate differences from its sibling:
///
/// 1. **It takes no `AppLocalizations`.** The diet engine resolves copy per rule
///    because each rule has its own rationale; here copy is 1:1 with the
///    protocol, so it is resolved at render time by `health_labels.dart`. That
///    keeps this file testable without a `BuildContext`.
/// 2. **It does not carry the dimension weights.** `cat_product_assessment.dart`
///    and `cat_diet_recommendations.dart` already hold two parallel copies of
///    `_wHealth`/`_wWeight`/… that must be changed in lockstep. A schedule is
///    ordered by *due date*, not by dimension priority, so it has no reason to
///    become a third copy. Keep it that way.
library;

import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_protocol.dart';
import 'package:yucat/features/health_carnet/presentation/models/health_due_item.dart';


/// Mean days per month (365.25 / 12). Used for every months ↔ days conversion so
/// the two directions agree.
const double _kDaysPerMonth = 30.4375;

/// Due within this many days reads as urgent (red).
const int _kUrgentDays = 7;

/// Due within this many days reads as soon (blue).
const int _kSoonDays = 30;

/// How far ahead the "upcoming" list looks.
///
/// A triennial FVRCP due in 2029 is not a to-do, and listing it would both bury
/// the real items and inflate the "à faire" count. Anything beyond a year drops
/// out until it comes into range.
const int _kHorizonDays = 365;

/// Approximate birth date from the profile's age in months.
///
/// ⚠️ `CatEntity.age` is captured once during the create wizard and **never
/// ages**, so this drifts by however long ago the profile was made. Two things
/// keep that survivable:
///
/// - It is only consulted for a protocol with **no completed record**. Once one
///   dose is logged, every later due date comes from `performedAt + interval`
///   and this is never read again — drift decays to nothing as the carnet fills.
/// - A protocol with no record whose derived date is already past renders as
///   [HealthUrgency.toSchedule], never as an overdue alarm.
///
/// Adding a real `birthDate` to the profile is the fix when kitten-series
/// accuracy becomes a complaint. Returns null when `cat.age` is null.
DateTime? estimatedBirthDate(CatEntity cat, DateTime now) {
  final months = cat.age;
  if (months == null) return null;
  return now.subtract(Duration(days: (months * _kDaysPerMonth).round()));
}

/// Every act this cat is due for, most pressing first.
///
/// Returns an empty list only for a profile that matches no protocol at all —
/// which in practice means every protocol has been completed or suppressed.
List<HealthDueItem> computeDueItems({
  required CatEntity cat,
  required List<HealthEventEntity> history,
  required DateTime now,
}) {
  final birth = estimatedBirthDate(cat, now);
  final ageMonths = cat.age?.toDouble();
  final hasConditions = cat.healthConditions?.isNotEmpty ?? false;

  final items = <HealthDueItem>[];

  for (final protocol in HealthProtocols.scheduled) {
    if (protocol.suppressWhenNeutered && cat.neutered) continue;
    if (protocol.requiresHealthCondition && !hasConditions) continue;

    final item = _dueItemFor(
      protocol: protocol,
      history: history,
      birth: birth,
      ageMonths: ageMonths,
      now: now,
    );
    if (item == null) continue;
    if ((item.daysUntil ?? 0) > _kHorizonDays) continue;
    items.add(item);
  }

  items.sort((a, b) {
    final byUrgency = a.urgency.rank.compareTo(b.urgency.rank);
    if (byUrgency != 0) return byUrgency;
    final da = a.dueDate;
    final db = b.dueDate;
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return da.compareTo(db);
  });

  return items;
}

/// One protocol's due item, or null when the protocol is complete for this cat
/// (every phase satisfied and nothing recurring left).
HealthDueItem? _dueItemFor({
  required HealthProtocol protocol,
  required List<HealthEventEntity> history,
  required DateTime? birth,
  required double? ageMonths,
  required DateTime now,
}) {
  final lastDone = _latestDone(history, protocol.id);

  DateTime due;
  int? intervalDays;
  var isSeriesDose = false;

  if (lastDone?.performedAt != null) {
    final performedAt = lastDone!.performedAt!;
    // The age the cat was *at that dose*, not today — a kitten dosed at 2 months
    // must follow the 3-weekly band even if it is 9 months old now.
    final ageThen = birth == null
        ? ageMonths
        : performedAt.difference(birth).inDays / _kDaysPerMonth;

    final phase = ageThen == null ? null : protocol.phaseAt(ageThen);
    // A per-record override wins: the rabies booster interval is a property of
    // the vial the vet used, not of the cat.
    final interval =
        lastDone.intervalDays ?? phase?.intervalDays ?? protocol.defaultIntervalDays;

    if (interval != null) {
      due = performedAt.add(Duration(days: interval));
      intervalDays = interval;
      isSeriesDose = phase?.toAgeMonths != null && interval <= 31;
    } else {
      // The dose satisfied a one-time phase (or landed in a gap between bands).
      // Advance to the next band rather than declaring the protocol finished —
      // this is what carries FVRCP from its 6-month booster to the triennial
      // adult schedule.
      final next = protocol.nextPhaseFrom((ageThen ?? 0) + 0.01);
      if (next == null || birth == null) return null;
      due = _dateAtAge(birth, next.fromAgeMonths);
      intervalDays = next.intervalDays;
      if (due.isBefore(performedAt)) due = performedAt;
    }
  } else {
    // No record. Earliest eligible = the start of whichever band applies now,
    // or of the next one the cat has yet to reach.
    if (birth == null) {
      return HealthDueItem(
        protocol: protocol,
        dueDate: null,
        urgency: HealthUrgency.toSchedule,
        intervalDays: protocol.phases.isEmpty
            ? null
            : protocol.phases.first.intervalDays,
      );
    }
    final phase = protocol.phaseAt(ageMonths ?? 0) ??
        protocol.nextPhaseFrom(ageMonths ?? 0);
    if (phase == null) return null;
    due = _dateAtAge(birth, phase.fromAgeMonths);
    intervalDays = phase.intervalDays;
    // The band may have opened years ago — an 11-year-old cat's first wellness
    // visit was "due" at 12 months. Surfacing that literal date would read as
    // "planned for September 2016", which is nonsense. What the owner actually
    // needs to know is that it applies *now*.
    if (due.isBefore(now)) due = now;
  }

  // A "Reporter" tap leaves a snoozed record carrying only a pushed-back date.
  // It is never history, so it cannot advance the interval — it can only move
  // this one occurrence later.
  final snoozedUntil = _latestSnoozeDue(history, protocol.id);
  if (snoozedUntil != null && snoozedUntil.isAfter(due)) {
    due = snoozedUntil;
  }

  final daysUntil = _wholeDaysBetween(now, due);
  final urgency = _urgencyFor(
    daysUntil: daysUntil,
    hasHistory: lastDone != null,
    wasSnoozed: snoozedUntil != null,
  );

  return HealthDueItem(
    protocol: protocol,
    dueDate: due,
    urgency: urgency,
    lastDone: lastDone,
    intervalDays: intervalDays,
    isSeriesDose: isSeriesDose,
    daysUntil: daysUntil,
  );
}

HealthUrgency _urgencyFor({
  required int daysUntil,
  required bool hasHistory,
  required bool wasSnoozed,
}) {
  // Nothing ever recorded, and the act already applies: that is a gap in the
  // *carnet*, not proof the cat missed anything. The owner may simply not have
  // logged it, and the date behind it comes from an approximated birth date.
  // Invite, don't alarm. A protocol the cat has not yet grown into keeps its
  // ordinary future urgency.
  if (!hasHistory && !wasSnoozed && daysUntil <= 0) {
    return HealthUrgency.toSchedule;
  }
  if (daysUntil < 0) return HealthUrgency.overdue;
  if (daysUntil <= _kUrgentDays) return HealthUrgency.urgent;
  if (daysUntil <= _kSoonDays) return HealthUrgency.soon;
  return HealthUrgency.later;
}

/// The most recently performed record satisfying [protocolId].
HealthEventEntity? _latestDone(
  List<HealthEventEntity> history,
  String protocolId,
) {
  HealthEventEntity? best;
  for (final event in history) {
    if (event.protocolId != protocolId) continue;
    if (event.status != HealthEventStatus.done) continue;
    if (event.performedAt == null) continue;
    if (best == null || event.performedAt!.isAfter(best.performedAt!)) {
      best = event;
    }
  }
  return best;
}

/// The furthest-out snooze recorded for [protocolId].
DateTime? _latestSnoozeDue(
  List<HealthEventEntity> history,
  String protocolId,
) {
  DateTime? best;
  for (final event in history) {
    if (event.protocolId != protocolId) continue;
    if (event.status != HealthEventStatus.snoozed) continue;
    final dueAt = event.dueAt;
    if (dueAt == null) continue;
    if (best == null || dueAt.isAfter(best)) best = dueAt;
  }
  return best;
}

DateTime _dateAtAge(DateTime birth, double ageMonths) =>
    birth.add(Duration(days: (ageMonths * _kDaysPerMonth).round()));

/// Calendar-day difference, so "due tomorrow" reads as 1 rather than 0 because
/// of a few hours' clock offset.
int _wholeDaysBetween(DateTime from, DateTime to) {
  final a = DateTime(from.year, from.month, from.day);
  final b = DateTime(to.year, to.month, to.day);
  return b.difference(a).inDays;
}

/// A weighing, for the history tab's chart.
class WeightPoint {
  final DateTime date;
  final double kg;

  const WeightPoint({required this.date, required this.kg});
}

/// One reading per month, chronological, capped at [maxMonths].
///
/// Months with no weighing are **skipped rather than drawn empty**: a cat weighed
/// three times a year would otherwise render as three bars in a field of gaps.
/// The trade-off is that the x-axis is not evenly spaced in time, which is why
/// each bar is labelled with its month and its actual value.
///
/// Where a month holds several weighings, the **last** one wins — it is the
/// current answer to "what does this cat weigh".
///
/// Shared by the chart and the summary tile on purpose, so the tile's "+0.3 kg
/// since April" can never disagree with the bars above it.
List<WeightPoint> monthlyWeightBuckets(
  List<WeightPoint> series, {
  int maxMonths = 6,
}) {
  final byMonth = <String, WeightPoint>{};
  for (final point in series) {
    // `series` is already oldest-first, so a later reading overwrites an earlier
    // one in the same month.
    byMonth['${point.date.year}-${point.date.month}'] = point;
  }
  final buckets = byMonth.values.toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  if (buckets.length <= maxMonths) return buckets;
  return buckets.sublist(buckets.length - maxMonths);
}

/// Every weight this carnet knows about, oldest first.
///
/// Reads **any** record carrying a `weightKg`, not just `weight`-category ones —
/// a wellness visit records a weight in passing, and the mockup's timeline shows
/// exactly that ("poids stable à 4,7 kg" on an annual visit).
List<WeightPoint> weightSeries(List<HealthEventEntity> history) {
  final points = <WeightPoint>[];
  for (final event in history) {
    final kg = event.weightKg;
    final date = event.performedAt;
    if (kg == null || date == null) continue;
    points.add(WeightPoint(date: date, kg: kg));
  }
  points.sort((a, b) => a.date.compareTo(b.date));
  return points;
}
