import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';
import 'package:yucat/features/health_carnet/domain/repositories/health_carnet_repository.dart';

class GetHealthEventsUsecase {
  final HealthCarnetRepository _repository;

  GetHealthEventsUsecase({required HealthCarnetRepository repository})
      : _repository = repository;

  Future<List<HealthEventEntity>> call({required String catId}) async {
    return await _repository.getEvents(catId: catId);
  }
}
