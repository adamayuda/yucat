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
