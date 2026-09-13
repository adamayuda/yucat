/// One recorded veterinary act for a cat — a vaccine injection, a deworming
/// dose, a wellness visit, a lab panel, a weigh-in.
///
/// Persisted at `cats/{catId}/health_events/{eventId}`. That subcollection
/// predates this feature: `CatDataSource.deleteCat` already cascade-deletes it,
/// so cat deletion cleans up records for free.
///
/// ⚠️ Enums persist by their stable [wire] string, never by index — reordering
/// an enum must not silently reinterpret saved rows. Same rule as
/// `litter_display_codec.dart`, for the same reason.
library;

/// What kind of act this is. Drives the timeline pill, the icon and the tint.
enum HealthCategory {
  vaccine('vaccine'),
  parasite('parasite'),
  exam('exam'),
  dental('dental'),
  surgery('surgery'),
  lab('lab'),
  identification('identification'),
  treatment('treatment'),
  weight('weight'),
  other('other');

  final String wire;

  const HealthCategory(this.wire);

  /// Unknown values degrade to [other] — a record written by a newer build must
  /// still render, just without a specialised icon.
  static HealthCategory fromWire(String? value) {
    for (final c in HealthCategory.values) {
      if (c.wire == value) return c;
    }
    return HealthCategory.other;
  }
}

/// Where the record sits relative to now.
///
/// A [done] record is history and advances the schedule. A [snoozed] record is
/// the residue of a "Reporter" tap — it carries only a pushed-back `dueAt` and
/// must never be read as history. [planned] is a user-scheduled future act.
/// [skipped] is recorded but deliberately not performed.
enum HealthEventStatus {
  done('done'),
  planned('planned'),
  snoozed('snoozed'),
  skipped('skipped');

  final String wire;

  const HealthEventStatus(this.wire);

  /// Returns null for an unrecognised value so the mapper can fall back on the
  /// document's own shape (see `HealthEventDocumentMapper`). Degrading blindly
  /// to [done] would let an unknown status advance the schedule.
  static HealthEventStatus? fromWire(String? value) {
    for (final s in HealthEventStatus.values) {
      if (s.wire == value) return s;
    }
    return null;
  }
}

class HealthEventEntity {
  /// Firestore doc id. Null only for an unsaved draft.
  final String? id;

  /// The protocol this record satisfies (`'rabies'`, `'deworming_internal'`, …),
  /// or null for a freeform act that no protocol schedules.
  ///
  /// This is the join key the schedule engine uses to decide what is due next,
  /// so it matters far more than [title].
  final String? protocolId;

  final HealthCategory category;
  final String title;
  final String? notes;
  final HealthEventStatus status;

  /// When the act was performed. Set iff [status] is `done`.
  final DateTime? performedAt;

  /// When the act is due. Set for `planned` and `snoozed`.
  final DateTime? dueAt;

  /// Per-record recurrence override, in days.
  ///
  /// Exists for rabies: the booster interval is a property of the vial the vet
  /// used (1 or 3 years), not of the cat, so it cannot live on the protocol.
  final int? intervalDays;

  /// Weight measured at this act, in kg. Allowed on **any** category, not just
  /// `weight` — a wellness visit records a weight in passing, and the chart
  /// reads every event that carries one.
  final double? weightKg;

  final String? vetName;
  final String? clinic;
  final DateTime? createdAt;

  const HealthEventEntity({
    this.id,
    this.protocolId,
    required this.category,
    required this.title,
    this.notes,
    required this.status,
    this.performedAt,
    this.dueAt,
    this.intervalDays,
    this.weightKg,
    this.vetName,
    this.clinic,
    this.createdAt,
  });

  bool get isDone => status == HealthEventStatus.done;

  /// The date this record sorts by, whichever end of time it sits at.
  DateTime? get effectiveDate => performedAt ?? dueAt ?? createdAt;
}
