import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';
import 'package:yucat/features/health_carnet/domain/repositories/health_carnet_repository.dart';

class AddHealthEventUsecase {
  final HealthCarnetRepository _repository;

  AddHealthEventUsecase({required HealthCarnetRepository repository})
      : _repository = repository;

  Future<HealthEventEntity> call({
    required String catId,
    required HealthEventEntity event,
  }) async {
    return await _repository.addEvent(catId: catId, event: event);
  }
}
