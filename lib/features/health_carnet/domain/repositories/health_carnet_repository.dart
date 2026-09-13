import 'dart:io';

import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';

/// The record was written but its photo was not. Carries the saved record so
/// the caller can keep it — losing a vaccination entry because a 2 MB upload
/// timed out would be the wrong trade.
class HealthAttachmentFailed implements Exception {
  final HealthEventEntity saved;
  final Object cause;

  const HealthAttachmentFailed(this.saved, this.cause);

  @override
  String toString() => 'HealthAttachmentFailed: $cause';
}

abstract class HealthCarnetRepository {
  /// Every record for the cat, most recent first.
  Future<List<HealthEventEntity>> getEvents({required String catId});

  /// Persists a record and returns it with its Firestore id attached. With
  /// [attachment], uploads the photo after the write and returns the record
  /// carrying its URL; throws [HealthAttachmentFailed] if only the upload
  /// failed.
  Future<HealthEventEntity> addEvent({
    required String catId,
    required HealthEventEntity event,
    File? attachment,
  });

  Future<void> deleteEvent({required String catId, required String eventId});
}
