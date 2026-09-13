import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/domain/entities/cat_vet_contact.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_protocol.dart';
import 'package:yucat/features/health_carnet/presentation/bloc/health_carnet_bloc.dart';
import 'package:yucat/features/health_carnet/presentation/utils/cat_health_schedule.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_share_text.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// The share note is the one carnet surface that leaves the app, so its
/// wording is pinned here against the English localizations.
void main() {
  // `healthFormatDate` goes through intl's DateFormat, which needs its locale
  // tables loaded outside a Flutter app.
  setUpAll(() => initializeDateFormatting('en'));
  final l10n = lookupAppLocalizations(const Locale('en'));
  final now = DateTime(2026, 9, 14);

  HealthEventEntity done(String id, DateTime on, {int? intervalDays, double? kg}) =>
      HealthEventEntity(
        id: id,
        protocolId: id,
        category: HealthProtocols.byId(id)!.category,
        title: '',
        status: HealthEventStatus.done,
        performedAt: on,
        intervalDays: intervalDays,
        weightKg: kg,
      );

  HealthCarnetLoadedState stateFor(CatEntity cat, List<HealthEventEntity> events) =>
      HealthCarnetLoadedState(
        cat: cat,
        events: events,
        dueItems: computeDueItems(cat: cat, history: events, now: now),
        weightPoints: weightSeries(events),
      );

  test('a full carnet renders every section', () {
    final cat = CatEntity(
      id: 'c',
      name: 'Milo',
      age: 36,
      birthDate: DateTime(2023, 9, 1),
      neutered: true,
      allergies: const ['chicken'],
      lifestyle: 'outdoor',
      vet: const CatVetContact(name: 'Dr Ruiz', clinic: 'VetSur', phone: '600'),
    );
    final events = [
      done('rabies', DateTime(2025, 10, 1), intervalDays: 1095),
      done('fvrcp', DateTime(2025, 10, 1)),
      done('annual_checkup', DateTime(2025, 10, 1), kg: 4.6),
    ];
    final text = buildHealthShareText(
      state: stateFor(cat, events),
      l10n: l10n,
      locale: 'en',
    );

    expect(text, startsWith('Milo · Health record'));
    expect(text, contains('Born: '));
    expect(text, contains('Age: 3 yrs'));
    expect(text, contains('Last weight: 4.6 kg'));
    expect(text, contains('Lifestyle: Goes outdoors'));
    expect(text, contains('Vaccines'));
    expect(text, contains('valid until'));
    expect(text, contains('Coming up'));
    expect(text, contains('Allergies: Chicken'));
    expect(text, contains('Vet: Dr Ruiz · VetSur · 600'));
    expect(text, endsWith('Shared from YuCat'));
  });

  test('an empty carnet says "no record" and skips the empty sections', () {
    final cat = CatEntity(id: 'c', name: 'Luna', age: 24, neutered: true);
    final text = buildHealthShareText(
      state: stateFor(cat, const []),
      l10n: l10n,
      locale: 'en',
    );
    expect('no record'.allMatches(text).length, 3);
    expect(text, isNot(contains('Coming up')));
    expect(text, isNot(contains('Allergies')));
    expect(text, isNot(contains('Vet:')));
    expect(text, isNot(contains('Born:')));
  });
}
