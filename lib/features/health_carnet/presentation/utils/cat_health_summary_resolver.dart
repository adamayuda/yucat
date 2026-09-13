/// The one read path every surface outside the carnet shares.
///
/// Home, Cat Detail, the cat list and Profile all want the same thing — "what
/// is the state of this cat's carnet" — and none of them is the carnet page,
/// so none of them should own a `HealthCarnetBloc`. This file gives them a
/// pure reducer over the records and a cache-or-fetch wrapper around it, so
/// the four surfaces cannot drift in how they count, pick the nearest item,
/// or treat a failed read.
///
/// ⚠️ A failed read resolves to **null**, never to an empty summary. "No
/// records" and "couldn't reach Firestore" must never look the same on a
/// surface that would then invite the owner to set up a carnet they already
/// filled in. Callers hide their health affordance on null, like Home does.
library;

import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';
import 'package:yucat/features/health_carnet/domain/usecases/get_health_events_usecase.dart';
import 'package:yucat/features/health_carnet/presentation/models/cat_health_summary.dart';
import 'package:yucat/features/health_carnet/presentation/models/health_due_item.dart';
import 'package:yucat/features/health_carnet/presentation/models/health_next_up.dart';
import 'package:yucat/features/health_carnet/presentation/utils/cat_health_schedule.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_events_cache.dart';

/// Pure: records + profile → summary. Flutter-free and I/O-free so it can be
/// exercised in `flutter test` without a widget or a Firestore fake.
CatHealthSummary summarizeCatHealth({
  required CatEntity cat,
  required List<HealthEventEntity> events,
  required DateTime now,
}) {
  final dueItems = computeDueItems(cat: cat, history: events, now: now);
  final nearest = nearestDueItem(dueItems);
  final hasHistory = events.any((e) => e.isDone);
  // Only a quiet carnet pays for the second pass: the next act beyond the
  // horizon is what the all-clear card names, and nothing else reads it.
  final beyond = nearest == null && hasHistory
      ? nearestDueItem(
          computeDueItems(cat: cat, history: events, now: now, horizonDays: null),
        )
      : null;
  return CatHealthSummary(
    cat: cat,
    events: events,
    dueItems: dueItems,
    nearest: nearest,
    nextBeyondHorizon: beyond,
  );
}

/// Home's card, chosen from the household's summaries. Pure, so the rules
/// are testable without a bloc:
///
/// 1. Any cat with a dated item → the earliest one, with the count of every
///    other overdue / urgent / soon item across the household.
/// 2. Else a cat with no history → its setup invitation.
/// 3. Else (every carnet set up and quiet) → all-clear, naming the earliest
///    act beyond the horizon if any cat has one.
/// 4. No summaries at all (no cats, or every read failed) → null.
///
/// Setup outranks all-clear on purpose: a household where one cat is
/// well-kept and another has never been set up is not "all clear".
HealthNextUp? resolveNextUp(List<CatHealthSummary> summaries) {
  if (summaries.isEmpty) return null;

  CatHealthSummary? nearestOwner;
  for (final summary in summaries) {
    final item = summary.nearest;
    if (item == null) continue;
    if (nearestOwner == null ||
        item.dueDate!.isBefore(nearestOwner.nearest!.dueDate!)) {
      nearestOwner = summary;
    }
  }
  if (nearestOwner != null) {
    final shown = nearestOwner.nearest!;
    var others = 0;
    for (final summary in summaries) {
      others += summary.dueSoonCount;
    }
    if (shown.urgency == HealthUrgency.overdue ||
        shown.urgency == HealthUrgency.urgent ||
        shown.urgency == HealthUrgency.soon) {
      others -= 1;
    }
    return HealthNextUpDue(
      cat: nearestOwner.cat,
      item: shown,
      othersDueCount: others < 0 ? 0 : others,
    );
  }

  for (final summary in summaries) {
    if (!summary.hasHistory) return HealthNextUpSetup(cat: summary.cat);
  }

  CatHealthSummary? nextOwner;
  for (final summary in summaries) {
    final item = summary.nextBeyondHorizon;
    if (item == null) continue;
    if (nextOwner == null ||
        item.dueDate!.isBefore(nextOwner.nextBeyondHorizon!.dueDate!)) {
      nextOwner = summary;
    }
  }
  return HealthNextUpAllClear(
    cat: (nextOwner ?? summaries.first).cat,
    nextItem: nextOwner?.nextBeyondHorizon,
  );
}

/// One cat, read through `health_events_cache.dart`.
///
/// After the first read of a session — or after any carnet write, which
/// refreshes the mirror — this costs no Firestore reads, which is what lets
/// Home re-fire on every tab visit and the cat list refetch on every return
/// from detail. Null when the cat has no id or the read fails.
Future<CatHealthSummary?> resolveCatHealth({
  required CatEntity cat,
  required GetHealthEventsUsecase getHealthEvents,
  required DateTime now,
}) async {
  final catId = cat.id;
  if (catId == null) return null;
  var events = cachedHealthEvents(catId);
  if (events == null) {
    try {
      events = await getHealthEvents(catId: catId);
      cacheHealthEvents(catId, events);
    } catch (_) {
      return null;
    }
  }
  return summarizeCatHealth(cat: cat, events: events, now: now);
}

/// Every cat in parallel; cats whose read failed are dropped rather than
/// failing the household. Order follows [cats].
Future<List<CatHealthSummary>> resolveHouseholdHealth({
  required List<CatEntity> cats,
  required GetHealthEventsUsecase getHealthEvents,
  required DateTime now,
}) async {
  final summaries = await Future.wait(
    cats.map(
      (cat) => resolveCatHealth(cat: cat, getHealthEvents: getHealthEvents, now: now),
    ),
  );
  return summaries.whereType<CatHealthSummary>().toList();
}
