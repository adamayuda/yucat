import 'package:flutter_test/flutter_test.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_protocol.dart';
import 'package:yucat/features/health_carnet/presentation/models/cat_health_summary.dart';
import 'package:yucat/features/health_carnet/presentation/models/health_due_item.dart';
import 'package:yucat/features/health_carnet/presentation/models/health_next_up.dart';
import 'package:yucat/features/health_carnet/presentation/utils/cat_health_schedule.dart';
import 'package:yucat/features/health_carnet/presentation/utils/cat_health_summary_resolver.dart';

/// `summarizeCatHealth` feeds every surface outside the carnet — Home's card,
/// the Cat Detail row, the cat-list pill — so its counts and its notion of
/// "has history" are what those surfaces agree on.
void main() {
  final now = DateTime(2026, 9, 13, 10);

  final cat = CatEntity(id: 'cat-1', name: 'Milo', age: 36, neutered: true);

  HealthEventEntity done(
    String protocolId, {
    required DateTime on,
    double? weightKg,
    int? intervalDays,
  }) =>
      HealthEventEntity(
        protocolId: protocolId,
        category: HealthProtocols.byId(protocolId)!.category,
        title: '',
        status: HealthEventStatus.done,
        performedAt: on,
        weightKg: weightKg,
        intervalDays: intervalDays,
      );

  HealthEventEntity snoozed(String protocolId, {required DateTime until}) =>
      HealthEventEntity(
        protocolId: protocolId,
        category: HealthProtocols.byId(protocolId)!.category,
        title: '',
        status: HealthEventStatus.snoozed,
        dueAt: until,
      );

  group('an empty carnet', () {
    final summary = summarizeCatHealth(cat: cat, events: const [], now: now);

    test('has no history, no records, no weight and nothing nearest', () {
      expect(summary.hasHistory, isFalse);
      expect(summary.recordCount, 0);
      expect(summary.latestWeightKg, isNull);
      expect(summary.nearest, isNull);
    });

    test('counts nothing as due — gaps are not deadlines', () {
      expect(summary.dueItems, isNotEmpty);
      expect(summary.pressingCount, 0);
      expect(summary.dueSoonCount, 0);
    });
  });

  test('a snooze alone is not history', () {
    final summary = summarizeCatHealth(
      cat: cat,
      events: [snoozed('rabies', until: now.add(const Duration(days: 20)))],
      now: now,
    );
    expect(summary.hasHistory, isFalse);
    expect(summary.recordCount, 0);
  });

  group('with records', () {
    final events = [
      done('deworming_internal', on: now.subtract(const Duration(days: 85))),
      done('annual_checkup',
          on: now.subtract(const Duration(days: 200)), weightKg: 4.4),
      done('parasite_external',
          on: now.subtract(const Duration(days: 10)), weightKg: 4.7),
      done('rabies', on: now.subtract(const Duration(days: 400))),
    ];
    final summary = summarizeCatHealth(cat: cat, events: events, now: now);

    test('counts done records and reads the latest weight', () {
      expect(summary.hasHistory, isTrue);
      expect(summary.recordCount, 4);
      expect(summary.latestWeightKg, 4.7);
    });

    test('nearest is the overdue rabies booster', () {
      expect(summary.nearest?.protocol.id, 'rabies');
      expect(summary.nearest?.urgency, HealthUrgency.overdue);
    });

    test('dueSoonCount covers overdue, urgent and soon only', () {
      // rabies overdue (35 d late), deworming urgent (6 d), external
      // antiparasitic soon (20 d); the check-up is 165 d out → later.
      expect(summary.pressingCount, 2);
      expect(summary.dueSoonCount, 3);
      final later = summary.dueItems
          .where((d) => d.urgency == HealthUrgency.later)
          .map((d) => d.protocol.id);
      expect(later, contains('annual_checkup'));
    });
  });

  group('the horizon', () {
    final events = [
      done('fvrcp', on: now.subtract(const Duration(days: 400))),
      done('deworming_internal', on: now.subtract(const Duration(days: 30))),
    ];

    test('can be lifted to see the triennial FVRCP', () {
      final within = computeDueItems(cat: cat, history: events, now: now);
      final all = computeDueItems(
        cat: cat,
        history: events,
        now: now,
        horizonDays: null,
      );
      expect(within.map((d) => d.protocol.id), isNot(contains('fvrcp')));
      expect(all.map((d) => d.protocol.id), contains('fvrcp'));
    });

    test('nextBeyondHorizon is only computed when nothing is inside', () {
      // Deworming comes back in ~61 days → nearest is set → no second pass.
      final busy = summarizeCatHealth(cat: cat, events: events, now: now);
      expect(busy.nearest?.protocol.id, 'deworming_internal');
      expect(busy.nextBeyondHorizon, isNull);
    });
  });

  group('resolveNextUp', () {
    CatEntity namedCat(String id) =>
        CatEntity(id: id, name: id, age: 36, neutered: true);

    CatHealthSummary summaryOf(
      CatEntity c,
      List<HealthEventEntity> events,
    ) =>
        summarizeCatHealth(cat: c, events: events, now: now);

    final dueSoon = [
      done('deworming_internal', on: now.subtract(const Duration(days: 85))),
      done('parasite_external', on: now.subtract(const Duration(days: 20))),
      done('annual_checkup', on: now.subtract(const Duration(days: 30))),
    ];

    test('nothing → null', () {
      expect(resolveNextUp(const []), isNull);
    });

    test('a dated item wins and counts the rest of the household', () {
      final a = summaryOf(namedCat('a'), dueSoon); // deworming 6d, external 10d
      final b = summaryOf(namedCat('b'), const []); // no history
      final next = resolveNextUp([b, a]);
      expect(next, isA<HealthNextUpDue>());
      final due = next as HealthNextUpDue;
      expect(due.cat.id, 'a');
      expect(due.item.protocol.id, 'deworming_internal');
      // a: deworming (urgent) + external (soon) → 2 due soon, minus the one shown.
      expect(due.othersDueCount, 1);
    });

    test('setup beats all-clear when a cat has no history', () {
      final a = summaryOf(namedCat('a'), const []);
      expect(resolveNextUp([a]), isA<HealthNextUpSetup>());
    });

    test('all set up and quiet → all-clear naming the next act', () {
      // Only long-interval acts are recorded: FVRCP (triennial) and a 3-year
      // rabies vial. Everything unrecorded is `toSchedule`, which `nearest`
      // ignores — so the carnet has history and nothing dated inside a year.
      final quiet = [
        done('fvrcp', on: now.subtract(const Duration(days: 365))),
        done('rabies', on: now.subtract(const Duration(days: 60)),
            intervalDays: 1095),
      ];
      final s = summaryOf(namedCat('a'), quiet);
      expect(s.hasHistory, isTrue);
      expect(s.nearest, isNull);
      expect(s.nextBeyondHorizon?.protocol.id, 'fvrcp');

      final next = resolveNextUp([s]);
      expect(next, isA<HealthNextUpAllClear>());
      expect((next as HealthNextUpAllClear).nextItem?.protocol.id, 'fvrcp');
    });

    test('all-clear picks the cat with the earliest act beyond the horizon',
        () {
      final a = CatHealthSummary(
        cat: namedCat('a'),
        events: [done('rabies', on: now)],
        dueItems: const [],
        nearest: null,
        nextBeyondHorizon: HealthDueItem(
          protocol: HealthProtocols.byId('fvrcp')!,
          dueDate: now.add(const Duration(days: 700)),
          urgency: HealthUrgency.later,
        ),
      );
      final b = CatHealthSummary(
        cat: namedCat('b'),
        events: [done('rabies', on: now)],
        dueItems: const [],
        nearest: null,
        nextBeyondHorizon: HealthDueItem(
          protocol: HealthProtocols.byId('senior_panel')!,
          dueDate: now.add(const Duration(days: 500)),
          urgency: HealthUrgency.later,
        ),
      );
      final next = resolveNextUp([a, b]) as HealthNextUpAllClear;
      expect(next.cat.id, 'b');
      expect(next.nextItem?.protocol.id, 'senior_panel');
    });
  });
}
