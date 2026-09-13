import 'package:flutter_test/flutter_test.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_protocol.dart';
import 'package:yucat/features/health_carnet/presentation/models/health_due_item.dart';
import 'package:yucat/features/health_carnet/presentation/utils/cat_health_schedule.dart';

/// The README §0 device checklist, as code, plus the two schedule bugs fixed in
/// phase 0 (an early dose pinned its band overdue for ever; a null-age cat was
/// offered kitten-only and senior-only acts).
void main() {
  final now = DateTime(2026, 9, 13, 10);

  CatEntity cat({
    int? age,
    bool neutered = true,
    List<String>? conditions,
  }) =>
      CatEntity(
        id: 'cat-1',
        name: 'Milo',
        age: age,
        neutered: neutered,
        healthConditions: conditions,
      );

  HealthEventEntity done(
    String protocolId, {
    required DateTime on,
    int? intervalDays,
  }) =>
      HealthEventEntity(
        protocolId: protocolId,
        category: HealthProtocols.byId(protocolId)!.category,
        title: '',
        status: HealthEventStatus.done,
        performedAt: on,
        intervalDays: intervalDays,
      );

  /// A dose given when the cat was [ageMonths] old, for a cat that is
  /// [catAgeMonths] old today. Mirrors `estimatedBirthDate`'s arithmetic.
  DateTime atAge(double ageMonths, {required int catAgeMonths}) {
    final birth = now.subtract(
      Duration(days: (catAgeMonths * 30.4375).round()),
    );
    return birth.add(Duration(days: (ageMonths * 30.4375).round()));
  }

  HealthDueItem? itemFor(List<HealthDueItem> items, String id) {
    for (final item in items) {
      if (item.protocol.id == id) return item;
    }
    return null;
  }

  group('an empty carnet', () {
    test('reads as gaps to schedule, never as missed acts', () {
      final items = computeDueItems(cat: cat(age: 36), history: [], now: now);

      expect(items, isNotEmpty);
      for (final item in items) {
        expect(item.urgency, HealthUrgency.toSchedule,
            reason: '${item.protocol.id} must not alarm with no history');
        expect(item.dueDate!.isBefore(now), isFalse,
            reason: '${item.protocol.id} must not show a fabricated past date');
      }
    });

    test('offers only what applies to a neutered adult with no conditions', () {
      final ids = computeDueItems(cat: cat(age: 36), history: [], now: now)
          .map((i) => i.protocol.id)
          .toSet();

      expect(ids, contains('annual_checkup'));
      expect(ids, contains('fvrcp'));
      expect(ids, isNot(contains('neutering')));
      expect(ids, isNot(contains('felv')), reason: 'kitten-only');
      expect(ids, isNot(contains('senior_panel')), reason: 'from 7 years');
      expect(ids, isNot(contains('condition_follow_up')));
      expect(ids, isNot(contains('dental_scaling')), reason: 'never scheduled');
    });

    test('adds neutering for an intact cat and a follow-up for a condition', () {
      final ids = computeDueItems(
        cat: cat(age: 36, neutered: false, conditions: ['kidney_disease']),
        history: [],
        now: now,
      ).map((i) => i.protocol.id).toSet();

      expect(ids, contains('neutering'));
      expect(ids, contains('condition_follow_up'));
    });
  });

  group('due dates from history', () {
    test('a deworming three months ago lands the next one about today', () {
      final items = computeDueItems(
        cat: cat(age: 36),
        history: [done('deworming_internal', on: now.subtract(const Duration(days: 91)))],
        now: now,
      );

      final item = itemFor(items, 'deworming_internal')!;
      expect(item.daysUntil, 0);
      expect(item.urgency, HealthUrgency.urgent);
      expect(item.lastDone, isNotNull);
    });

    test('a kitten under 6 months follows the 3-weekly FVRCP series', () {
      final items = computeDueItems(
        cat: cat(age: 3, neutered: false),
        history: [done('fvrcp', on: now.subtract(const Duration(days: 14)))],
        now: now,
      );

      final item = itemFor(items, 'fvrcp')!;
      expect(item.isSeriesDose, isTrue);
      expect(item.intervalDays, 21);
      expect(item.daysUntil, 7);
    });

    test('the rabies interval comes from the record, not the protocol', () {
      final items = computeDueItems(
        cat: cat(age: 36),
        history: [
          done('rabies', on: now.subtract(const Duration(days: 800)), intervalDays: 1095),
        ],
        now: now,
      );

      // A 3-year vial: 295 days out, inside the horizon; the protocol's own
      // 365-day default would have put it 435 days in the past.
      expect(itemFor(items, 'rabies')!.daysUntil, 1095 - 800);
    });

    test('anything more than a year out drops off the list', () {
      final items = computeDueItems(
        cat: cat(age: 36),
        history: [done('fvrcp', on: now.subtract(const Duration(days: 30)))],
        now: now,
      );

      expect(itemFor(items, 'fvrcp'), isNull, reason: 'triennial, due in ~3 years');
    });

    test('a snooze pushes one occurrence out without becoming history', () {
      final snooze = HealthEventEntity(
        protocolId: 'deworming_internal',
        category: HealthCategory.parasite,
        title: '',
        status: HealthEventStatus.snoozed,
        dueAt: now.add(const Duration(days: 10)),
      );
      final items = computeDueItems(
        cat: cat(age: 36),
        history: [
          done('deworming_internal', on: now.subtract(const Duration(days: 120))),
          snooze,
        ],
        now: now,
      );

      final item = itemFor(items, 'deworming_internal')!;
      expect(item.daysUntil, 10);
      expect(item.urgency, HealthUrgency.soon);
      expect(item.lastDone!.status, HealthEventStatus.done);
    });

    test('an overdue item sorts before a to-schedule one', () {
      final items = computeDueItems(
        cat: cat(age: 36),
        history: [done('deworming_internal', on: now.subtract(const Duration(days: 200)))],
        now: now,
      );

      expect(items.first.protocol.id, 'deworming_internal');
      expect(items.first.urgency, HealthUrgency.overdue);
      expect(items.last.urgency, HealthUrgency.toSchedule);
    });
  });

  group('an early dose counts for the band it stood in for', () {
    test('neutering at 3 months completes the protocol', () {
      final items = computeDueItems(
        cat: cat(age: 5, neutered: false),
        history: [done('neutering', on: atAge(3, catAgeMonths: 5))],
        now: now,
      );

      expect(itemFor(items, 'neutering'), isNull);
    });

    test('a microchip at 6 weeks completes the protocol', () {
      final items = computeDueItems(
        cat: cat(age: 4),
        history: [done('microchip', on: atAge(1.5, catAgeMonths: 4))],
        now: now,
      );

      expect(itemFor(items, 'microchip'), isNull);
    });

    test('the 6-month FVRCP booster given at 5½ months moves on to the '
        'triennial band', () {
      final items = computeDueItems(
        cat: cat(age: 7),
        history: [done('fvrcp', on: atAge(5.5, catAgeMonths: 7))],
        now: now,
      );

      final item = itemFor(items, 'fvrcp')!;
      expect(item.urgency, isNot(HealthUrgency.overdue));
      expect(item.intervalDays, 1095);
      // Due when the adult band opens, at 12 months — about 5 months out.
      expect(item.daysUntil, inInclusiveRange(140, 165));
    });

    test('a dose well before a band still leaves that band to do', () {
      // 4½ months is a kitten-series dose, not the 6-month booster.
      final items = computeDueItems(
        cat: cat(age: 7),
        history: [done('fvrcp', on: atAge(4.5, catAgeMonths: 7))],
        now: now,
      );

      final item = itemFor(items, 'fvrcp')!;
      expect(item.urgency, HealthUrgency.overdue);
      expect(item.daysUntil, inInclusiveRange(-35, -25), reason: 'due at 6 months');
    });

    test('a first annual visit at 11 months starts the yearly cadence there', () {
      final items = computeDueItems(
        cat: cat(age: 14),
        history: [done('annual_checkup', on: atAge(11, catAgeMonths: 14))],
        now: now,
      );

      final item = itemFor(items, 'annual_checkup')!;
      expect(item.urgency, HealthUrgency.later);
      expect(item.daysUntil, inInclusiveRange(265, 280), reason: '365 days after the visit');
    });
  });

  group('a real birth date', () {
    test('is preferred over the months approximation', () {
      final birth = DateTime(2026, 6, 20);
      final withDate = CatEntity(name: 'Kit', age: 2, birthDate: birth);
      expect(estimatedBirthDate(withDate, now), birth);
      expect(estimatedBirthDate(cat(age: 2), now), isNot(birth));
    });

    test('dates the kitten series from the birthday, not the snapshot', () {
      // Born 20 June: 12 weeks old on 12 September, first FVRCP band opened at
      // 6 weeks. With a 3-weekly dose two weeks ago the next one is in 7 days.
      final birth = DateTime(2026, 6, 20);
      final kit = CatEntity(name: 'Kit', age: 2, birthDate: birth);
      final items = computeDueItems(
        cat: kit,
        history: [done('fvrcp', on: now.subtract(const Duration(days: 14)))],
        now: now,
      );
      final item = itemFor(items, 'fvrcp')!;
      expect(item.isSeriesDose, isTrue);
      expect(item.daysUntil, 7);
    });
  });

  group('a cat with no age', () {
    test('is offered only lifelong acts, all undated', () {
      final items = computeDueItems(cat: cat(age: null), history: [], now: now);
      final ids = items.map((i) => i.protocol.id).toSet();

      expect(ids, contains('annual_checkup'));
      expect(ids, contains('fvrcp'));
      expect(ids, contains('rabies'));
      expect(ids, isNot(contains('felv')));
      expect(ids, isNot(contains('senior_panel')));
      for (final item in items) {
        expect(item.dueDate, isNull);
        expect(item.urgency, HealthUrgency.toSchedule);
      }
    });

    test('still dates an act from its record', () {
      final items = computeDueItems(
        cat: cat(age: null),
        history: [
          done('rabies', on: now.subtract(const Duration(days: 100)), intervalDays: 365),
        ],
        now: now,
      );

      expect(itemFor(items, 'rabies')!.daysUntil, 265);
    });
  });

  group('nearestDueItem', () {
    test('ignores to-schedule rows and picks the earliest date', () {
      final items = computeDueItems(
        cat: cat(age: 36),
        history: [
          done('deworming_internal', on: now.subtract(const Duration(days: 80))),
          done('parasite_external', on: now.subtract(const Duration(days: 25))),
        ],
        now: now,
      );

      final nearest = nearestDueItem(items)!;
      expect(nearest.protocol.id, 'parasite_external', reason: 'due in 5 days');
      expect(nearest.urgency, isNot(HealthUrgency.toSchedule));
    });

    test('is null for an empty carnet — nothing dated to surface', () {
      final items = computeDueItems(cat: cat(age: 36), history: [], now: now);
      expect(nearestDueItem(items), isNull);
    });
  });

  group('monthlyWeightBuckets', () {
    WeightPoint p(int year, int month, int day, double kg) =>
        WeightPoint(date: DateTime(year, month, day), kg: kg);

    test('keeps the latest reading of each month and skips empty months', () {
      final buckets = monthlyWeightBuckets([
        p(2026, 3, 2, 4.1),
        p(2026, 3, 20, 4.3),
        p(2026, 6, 1, 4.6),
      ]);

      expect(buckets.map((b) => b.kg), [4.3, 4.6]);
    });

    test('caps at the most recent months, chronologically', () {
      final buckets = monthlyWeightBuckets(
        [for (var m = 1; m <= 9; m++) p(2026, m, 1, m.toDouble())],
        maxMonths: 6,
      );

      expect(buckets.map((b) => b.date.month), [4, 5, 6, 7, 8, 9]);
    });
  });

  test('weightSeries reads any record carrying a weight, oldest first', () {
    final series = weightSeries([
      HealthEventEntity(
        category: HealthCategory.exam,
        title: '',
        status: HealthEventStatus.done,
        performedAt: DateTime(2026, 5, 1),
        weightKg: 4.5,
      ),
      HealthEventEntity(
        category: HealthCategory.weight,
        title: '',
        status: HealthEventStatus.done,
        performedAt: DateTime(2026, 2, 1),
        weightKg: 4.2,
      ),
      HealthEventEntity(
        category: HealthCategory.vaccine,
        title: '',
        status: HealthEventStatus.done,
        performedAt: DateTime(2026, 3, 1),
      ),
    ]);

    expect(series.map((s) => s.kg), [4.2, 4.5]);
  });
}
