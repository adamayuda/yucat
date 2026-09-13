import 'package:yucat/features/health_carnet/domain/repositories/health_carnet_repository.dart';

class DeleteHealthEventUsecase {
  final HealthCarnetRepository _repository;

  DeleteHealthEventUsecase({required HealthCarnetRepository repository})
      : _repository = repository;

  Future<void> call({required String catId, required String eventId}) async {
    return await _repository.deleteEvent(catId: catId, eventId: eventId);
  }
}
