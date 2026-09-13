import 'dart:io';

import 'package:yucat/features/cat/domain/repositories/cat_repository.dart';

/// Replaces (or adds) a cat's profile photo without touching the rest of the
/// document — the in-place edit behind the tappable avatar on Cat Detail.
///
/// Order matters: upload, then point the document at the new URL, then drop
/// the previous object. Deleting first would leave the profile pointing at
/// nothing if either later step failed. Returns the new download URL.
class UpdateCatPhotoUsecase {
  final CatRepository _repository;

  UpdateCatPhotoUsecase({required CatRepository repository})
      : _repository = repository;

  Future<String> call({
    required String catId,
    required File imageFile,
    String? previousImageUrl,
  }) async {
    final url = await _repository.uploadCatProfileImage(
      imageFile: imageFile,
      catId: catId,
    );
    if (url == null) {
      throw Exception('Failed to upload profile image');
    }

    await _repository.updateCatProfileImageUrl(
      catId: catId,
      profileImageUrl: url,
    );

    if (previousImageUrl != null &&
        previousImageUrl.isNotEmpty &&
        previousImageUrl != url) {
      await _repository.deleteCatProfileImage(imageUrl: previousImageUrl);
    }

    return url;
  }
}
