import 'package:yucat/features/health_carnet/domain/entities/health_booklet_proposal.dart';
import 'package:yucat/features/health_carnet/domain/repositories/health_booklet_repository.dart';

class ReadHealthBookletUsecase {
  final HealthBookletRepository _repository;

  ReadHealthBookletUsecase({required HealthBookletRepository repository})
      : _repository = repository;

  Future<HealthBookletProposal> call({
    required String imageBase64,
    required DateTime today,
    String? catName,
  }) {
    final y = today.year.toString().padLeft(4, '0');
    final m = today.month.toString().padLeft(2, '0');
    final d = today.day.toString().padLeft(2, '0');
    return _repository.readBooklet(
      imageBase64: imageBase64,
      today: '$y-$m-$d',
      catName: catName,
    );
  }
}
