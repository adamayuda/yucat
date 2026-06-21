import 'dart:io';

import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/domain/repositories/cat_repository.dart';

class UpdateCatUsecase {
  final CatRepository _repository;

  UpdateCatUsecase({required CatRepository repository})
      : _repository = repository;

  /// Updates [cat]. When [profileImageFile] is provided (the user picked a new
  /// photo in the edit wizard), it is uploaded to Storage first and the
  /// resulting URL persisted — mirroring [CreateCatUsecase]. Without this the
  /// edited photo was silently dropped (the entity carries no file field).
  Future<void> call({required CatEntity cat, File? profileImageFile}) async {
    var updated = cat;

    if (profileImageFile != null && cat.id != null) {
      final url = await _repository.uploadCatProfileImage(
        imageFile: profileImageFile,
        catId: cat.id!,
      );
      if (url != null) {
        updated = cat.copyWith(profileImageUrl: url);
      }
    }

    return _repository.updateCat(cat: updated);
  }
}
