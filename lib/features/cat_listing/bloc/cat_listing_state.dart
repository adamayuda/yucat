part of 'cat_listing_bloc.dart';

sealed class CatListingState extends Equatable {
  const CatListingState();
}

class CatListingLoadingState extends CatListingState {
  const CatListingLoadingState();

  @override
  List<Object?> get props => [];
}

class CatListingLoadedState extends CatListingState {
  final List<CatModel> cats;

  const CatListingLoadedState({required this.cats});

  @override
  List<Object?> get props => [cats];
}

class CatListingErrorState extends CatListingState {
  final String message;

  const CatListingErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
