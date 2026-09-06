import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';

abstract class HealthCarnetRepository {
  /// Every record for the cat, most recent first.
  Future<List<HealthEventEntity>> getEvents({required String catId});

  /// Persists a record and returns it with its Firestore id attached.
  Future<HealthEventEntity> addEvent({
    required String catId,
    required HealthEventEntity event,
  });

  Future<void> deleteEvent({required String catId, required String eventId});
}
