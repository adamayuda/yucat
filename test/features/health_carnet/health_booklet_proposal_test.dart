import 'package:flutter_test/flutter_test.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_booklet_proposal.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';

/// `toDraft` is the seam between what the reader proposes and what the carnet
/// stores; it must honour the add sheet's contract or a booklet import would
/// render differently from a hand-typed record.
void main() {
  final date = DateTime(2024, 3, 12);

  HealthBookletRecord record({
    String? protocolId,
    String title = 'Purevax RCP',
    HealthCategory category = HealthCategory.vaccine,
    int? intervalDays,
    HealthBookletConfidence confidence = HealthBookletConfidence.high,
  }) =>
      HealthBookletRecord(
        protocolId: protocolId,
        title: title,
        category: category,
        performedAt: date,
        intervalDays: intervalDays,
        vet: 'Dr Ruiz',
        confidence: confidence,
      );

  test('a protocol-backed record stores an empty title and its category', () {
    final draft = record(protocolId: 'fvrcp').toDraft();
    expect(draft.protocolId, 'fvrcp');
    expect(draft.title, '');
    expect(draft.category, HealthCategory.vaccine);
    expect(draft.status, HealthEventStatus.done);
    expect(draft.performedAt, date);
    expect(draft.vetName, 'Dr Ruiz');
  });

  test('a freeform act keeps its transcribed title', () {
    final draft = record(title: 'Détartrage', category: HealthCategory.dental)
        .toDraft();
    expect(draft.protocolId, isNull);
    expect(draft.title, 'Détartrage');
    expect(draft.category, HealthCategory.dental);
  });

  test('an unknown id degrades to freeform, never to a wrong protocol', () {
    final draft = record(protocolId: 'fip', title: 'FIP').toDraft();
    expect(draft.protocolId, isNull);
    expect(draft.title, 'FIP');
  });

  test('the interval survives on rabies only', () {
    expect(record(protocolId: 'rabies', intervalDays: 1095).toDraft().intervalDays, 1095);
    expect(record(protocolId: 'fvrcp', intervalDays: 1095).toDraft().intervalDays, isNull);
  });

  test('low-confidence rows start unticked', () {
    expect(record().acceptedByDefault, isTrue);
    expect(
      record(confidence: HealthBookletConfidence.low).acceptedByDefault,
      isFalse,
    );
  });

  test('wire enums degrade safely', () {
    expect(HealthBookletOutcome.fromWire('garbage'), HealthBookletOutcome.records);
    expect(HealthBookletOutcome.fromWire('not_booklet'), HealthBookletOutcome.notBooklet);
    expect(HealthBookletConfidence.fromWire(null), HealthBookletConfidence.low);
  });
}
