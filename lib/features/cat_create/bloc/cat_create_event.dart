part of 'cat_create_bloc.dart';

sealed class CatCreateEvent extends Equatable {
  const CatCreateEvent();
}

class CatCreateInitialEvent extends CatCreateEvent {
  const CatCreateInitialEvent();

  @override
  List<Object?> get props => [];
}

class CatCreateCatEvent extends CatCreateEvent {
  final CatCreateModel cat;

  const CatCreateCatEvent({required this.cat});

  @override
  List<Object?> get props => [cat];
}
