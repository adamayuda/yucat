import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';

/// Document ↔ entity for `cats/{catId}/health_events/{eventId}`.
///
/// ⚠️ **This is the app's only `Timestamp` ↔ `DateTime` boundary.** Nothing else
/// in the codebase persists a date to Firestore, so there was no precedent to
/// follow — every other model stores primitives. Keep the conversion here rather
/// than letting `Timestamp` leak into the domain, and do not hand-roll a second
/// copy: the food side has two byte-identical codecs in unrelated features, and
/// that duplication is why `dataUnavailable` had to be fixed twice.
///
/// Field names are `snake_case`, matching the dominant convention in
/// `CatDataSource` (`age_group`, `health_conditions`, …).
abstract class HealthEventDocumentMapper {
  HealthEventEntity call(DocumentSnapshot<Map<String, dynamic>> doc);
  Map<String, dynamic> toDocument(HealthEventEntity entity);
}

class HealthEventDocumentMapperImpl implements HealthEventDocumentMapper {
  const HealthEventDocumentMapperImpl();

  @override
  HealthEventEntity call(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final performedAt = _toDate(data['performed_at']);

    return HealthEventEntity(
      id: doc.id,
      protocolId: data['protocol_id'] as String?,
      category: HealthCategory.fromWire(data['category'] as String?),
      title: data['title'] as String? ?? '',
      notes: _emptyToNull(data['notes'] as String?),
      // An unrecognised status falls back on the document's own shape rather
      // than blindly on `done` — an unknown status that advanced the schedule
      // would silently push a real booster into the future.
      status: HealthEventStatus.fromWire(data['status'] as String?) ??
          (performedAt != null
              ? HealthEventStatus.done
              : HealthEventStatus.planned),
      performedAt: performedAt,
      dueAt: _toDate(data['due_at']),
      intervalDays: (data['interval_days'] as num?)?.toInt(),
      weightKg: (data['weight_kg'] as num?)?.toDouble(),
      vetName: _emptyToNull(data['vet_name'] as String?),
      clinic: _emptyToNull(data['clinic'] as String?),
      createdAt: _toDate(data['created_at']),
    );
  }

  @override
  Map<String, dynamic> toDocument(HealthEventEntity entity) {
    return {
      if (entity.protocolId != null) 'protocol_id': entity.protocolId,
      'category': entity.category.wire,
      'title': entity.title,
      if (entity.notes != null) 'notes': entity.notes,
      'status': entity.status.wire,
      if (entity.performedAt != null)
        'performed_at': Timestamp.fromDate(entity.performedAt!),
      if (entity.dueAt != null) 'due_at': Timestamp.fromDate(entity.dueAt!),
      if (entity.intervalDays != null) 'interval_days': entity.intervalDays,
      if (entity.weightKg != null) 'weight_kg': entity.weightKg,
      if (entity.vetName != null) 'vet_name': entity.vetName,
      if (entity.clinic != null) 'clinic': entity.clinic,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  /// Tolerates a `Timestamp`, an ISO-8601 string, or epoch millis. Only
  /// `Timestamp` is ever written, but a hand-edited console document or a
  /// future import path should not crash the whole carnet.
  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static String? _emptyToNull(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
