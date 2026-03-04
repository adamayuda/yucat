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

  const CatDetailLoadedState({required this.cat});

  @override
  List<Object?> get props => [cat];
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

class CatDetailNavigateToEditState extends CatDetailState {
  final CatModel cat;

  const CatDetailNavigateToEditState({required this.cat});

  @override
  List<Object?> get props => [cat];
}
