part of 'cat_detail_bloc.dart';

sealed class CatDetailState extends Equatable {
  const CatDetailState();
}

class CatDetailInitialState extends CatDetailState {
  @override
  List<Object?> get props => [];
}

class CatDetailLoadedState extends CatDetailState {
  final CatModel cat;

  /// True while a new profile photo is uploading; the hero shows a progress
  /// ring over the avatar and ignores further taps.
  final bool isUploadingPhoto;

  const CatDetailLoadedState({required this.cat, this.isUploadingPhoto = false});

  @override
  List<Object?> get props => [cat, isUploadingPhoto];
}

class CatDetailLoadingState extends CatDetailState {
  @override
  List<Object?> get props => [];
}

class CatDetailDeletedState extends CatDetailState {
  @override
  List<Object?> get props => [];
}

class CatDetailErrorState extends CatDetailState {
  final String message;

  const CatDetailErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Transient: the photo upload failed. Always followed by a
/// [CatDetailLoadedState] carrying the unchanged cat, so the builder never
/// has to render this one.
class CatDetailPhotoErrorState extends CatDetailState {
  @override
  List<Object?> get props => [];
}

class CatDetailNavigateToEditState extends CatDetailState {
  final CatModel cat;

  const CatDetailNavigateToEditState({required this.cat});

  @override
  List<Object?> get props => [cat];
}
