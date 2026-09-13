part of 'cat_detail_bloc.dart';

sealed class CatDetailEvent extends Equatable {
  const CatDetailEvent();
}

class CatDetailInitialEvent extends CatDetailEvent {
  final CatModel cat;

  const CatDetailInitialEvent({required this.cat});

  @override
  List<Object?> get props => [cat];
}

class CatDetailDeleteEvent extends CatDetailEvent {
  final String catId;

  const CatDetailDeleteEvent({required this.catId});

  @override
  List<Object?> get props => [catId];
}

class CatDetailEditEvent extends CatDetailEvent {
  final CatModel cat;

  const CatDetailEditEvent({required this.cat});

  @override
  List<Object?> get props => [cat];
}

/// The user picked a new profile photo from the hero avatar.
class CatDetailPhotoChangedEvent extends CatDetailEvent {
  final CatModel cat;
  final File photo;

  const CatDetailPhotoChangedEvent({required this.cat, required this.photo});

  @override
  List<Object?> get props => [cat, photo.path];
}

/// Re-reads the cat after the edit wizard returns, so the page reflects what
/// was saved instead of the model it was pushed with.
class CatDetailReloadEvent extends CatDetailEvent {
  final String catId;

  const CatDetailReloadEvent({required this.catId});

  @override
  List<Object?> get props => [catId];
}

/// Re-derives the carnet summary — fired on return from the carnet, which may
/// have added, completed or deleted records. Cheap: the carnet keeps the
/// events mirror current, so this is a recompute, not a fetch.
class CatDetailHealthRefreshEvent extends CatDetailEvent {
  const CatDetailHealthRefreshEvent();

  @override
  List<Object?> get props => [];
}
