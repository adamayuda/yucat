import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/domain/repositories/cat_repository.dart';

class GetCatsUsecase {
  final CatRepository _repository;

  GetCatsUsecase({required CatRepository repository})
    : _repository = repository;

  Future<List<CatEntity>> call({required String userId}) async {
    return await _repository.getCats(userId: userId);
  }
}
