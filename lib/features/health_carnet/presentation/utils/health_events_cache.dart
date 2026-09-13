import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';

/// Process-global mirror of each cat's `health_events` subcollection, keyed by
/// cat id — the `_cache` pattern from `cat_product_recommendations.dart`.
///
/// Home re-fires `HomeInitialEvent` on every tab visit, after every scan and on
/// Cancel; without this each fire would re-read every cat's whole subcollection
/// (plus the rule's `get()` per document) just to find the nearest due date.
///
/// The carnet's repository stays uncached on purpose — the page writes what it
/// reads — so this is not a read-through cache on the repository. It is kept
/// *by the writer*: `HealthCarnetBloc` stores the full list every time it
/// re-derives, so after any add / done / snooze / delete Home sees the new
/// records without a fetch. Home fills a missing entry on its first read of a
/// session. Stale only across devices, and a cold launch starts empty.
///
/// ⚠️ Events are cached, not the computed schedule: `computeDueItems` takes
/// `now`, and a cached "next up" would go stale at midnight.
final Map<String, List<HealthEventEntity>> _cache = {};

List<HealthEventEntity>? cachedHealthEvents(String catId) => _cache[catId];

void cacheHealthEvents(String catId, List<HealthEventEntity> events) {
  _cache[catId] = List.unmodifiable(events);
}

/// Drops one cat's entry (a deleted cat) or, with null, everything (the QA
/// "Reset test user" flow, which starts a brand-new uid).
void invalidateHealthEventsCache([String? catId]) {
  if (catId == null) {
    _cache.clear();
  } else {
    _cache.remove(catId);
  }
}
