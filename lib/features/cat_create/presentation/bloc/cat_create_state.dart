part of 'cat_create_bloc.dart';

sealed class CatCreateState extends Equatable {
  const CatCreateState();
}

class CatCreateLoadingState extends CatCreateState {
  const CatCreateLoadingState();

  @override
  List<Object?> get props => [];
}

class CatCreateLoadedState extends CatCreateState {
  const CatCreateLoadedState();

  @override
  List<Object?> get props => [];
}

class CatCreateErrorState extends CatCreateState {
  final String message;

  const CatCreateErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
