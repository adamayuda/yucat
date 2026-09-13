import 'package:yucat/features/health_carnet/data/datasources/health_event_datasource.dart';
import 'package:yucat/features/health_carnet/data/mappers/health_event_document_mapper.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';
import 'package:yucat/features/health_carnet/domain/repositories/health_carnet_repository.dart';

class HealthCarnetRepositoryImpl implements HealthCarnetRepository {
  final HealthEventDataSource _dataSource;
  final HealthEventDocumentMapper _mapper;

  HealthCarnetRepositoryImpl({
    required HealthEventDataSource dataSource,
    required HealthEventDocumentMapper mapper,
  })  : _dataSource = dataSource,
        _mapper = mapper;

  /// ⚠️ Deliberately **not** cached, unlike `RecipesRepositoryImpl`.
  ///
  /// Recipes are a read-only catalogue shared by two screens; health records are
  /// written by the very page that reads them, so a cache would show a stale
  /// carnet the moment a user marked a booster done.
  @override
  Future<List<HealthEventEntity>> getEvents({required String catId}) async {
    final snapshot = await _dataSource.getEvents(catId: catId);
    final events = snapshot.docs.map((doc) => _mapper(doc)).toList();
    // Sorted here rather than in the query so no composite index is needed.
    // Records with no date at all sort last.
    events.sort((a, b) {
      final da = a.effectiveDate;
      final db = b.effectiveDate;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });
    return events;
  }

  @override
  Future<HealthEventEntity> addEvent({
    required String catId,
    required HealthEventEntity event,
  }) async {
    final docRef = await _dataSource.addEvent(
      catId: catId,
      data: _mapper.toDocument(event),
    );
    return HealthEventEntity(
      id: docRef.id,
      protocolId: event.protocolId,
      category: event.category,
      title: event.title,
      notes: event.notes,
      status: event.status,
      performedAt: event.performedAt,
      dueAt: event.dueAt,
      intervalDays: event.intervalDays,
      weightKg: event.weightKg,
      vetName: event.vetName,
      clinic: event.clinic,
      // The document's own `created_at` is a server timestamp we have not read
      // back; the local clock is close enough for ordering an unsaved-then-saved
      // record within the session.
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteEvent({
    required String catId,
    required String eventId,
  }) async {
    await _dataSource.deleteEvent(catId: catId, eventId: eventId);
  }
}
