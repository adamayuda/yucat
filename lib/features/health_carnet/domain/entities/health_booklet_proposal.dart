import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_protocol.dart';

/// What the booklet reader made of the photo.
enum HealthBookletOutcome {
  records,
  unreadable,
  notBooklet;

  static HealthBookletOutcome fromWire(String? value) => switch (value) {
        'unreadable' => HealthBookletOutcome.unreadable,
        'not_booklet' => HealthBookletOutcome.notBooklet,
        _ => HealthBookletOutcome.records,
      };
}

enum HealthBookletConfidence {
  high,
  medium,
  low;

  static HealthBookletConfidence fromWire(String? value) => switch (value) {
        'high' => HealthBookletConfidence.high,
        'medium' => HealthBookletConfidence.medium,
        _ => HealthBookletConfidence.low,
      };
}

/// One act the reader found on the page — a *proposal*, never written until
/// the owner ticks it in the review sheet.
class HealthBookletRecord {
  /// A known protocol id, or null for an act no protocol schedules.
  final String? protocolId;
  final String title;
  final HealthCategory category;
  final DateTime performedAt;
  final int? intervalDays;
  final String? vet;
  final String? clinic;
  final HealthBookletConfidence confidence;

  const HealthBookletRecord({
    required this.protocolId,
    required this.title,
    required this.category,
    required this.performedAt,
    this.intervalDays,
    this.vet,
    this.clinic,
    required this.confidence,
  });

  /// Ticked by default unless the reader was unsure — a low-confidence row
  /// starts unticked so a misread never lands by inertia.
  bool get acceptedByDefault => confidence != HealthBookletConfidence.low;

  HealthBookletRecord copyWith({DateTime? performedAt}) => HealthBookletRecord(
        protocolId: protocolId,
        title: title,
        category: category,
        performedAt: performedAt ?? this.performedAt,
        intervalDays: intervalDays,
        vet: vet,
        clinic: clinic,
        confidence: confidence,
      );

  /// The record to write. Same contract as the add sheet: a protocol-backed
  /// record stores an **empty** title (the timeline names it from the id, in
  /// whatever language the app is in later); only a freeform act keeps the
  /// transcribed title. An id the catalogue does not know degrades to freeform
  /// rather than to a wrong protocol.
  HealthEventEntity toDraft() {
    final protocol = HealthProtocols.byId(protocolId);
    return HealthEventEntity(
      protocolId: protocol?.id,
      category: protocol?.category ?? category,
      title: protocol == null ? title : '',
      status: HealthEventStatus.done,
      performedAt: performedAt,
      intervalDays: protocol?.id == 'rabies' ? intervalDays : null,
      vetName: vet,
      clinic: clinic,
    );
  }
}

class HealthBookletProposal {
  final HealthBookletOutcome outcome;
  final List<HealthBookletRecord> records;

  const HealthBookletProposal({required this.outcome, required this.records});
}
