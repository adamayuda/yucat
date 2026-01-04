part of 'cat_listing_bloc.dart';

sealed class CatListingEvent extends Equatable {
  const CatListingEvent();
}

class CatListingInitialEvent extends CatListingEvent {
  const CatListingInitialEvent();

  @override
  List<Object?> get props => [];
}

class CatListingFetchCatsEvent extends CatListingEvent {
  const CatListingFetchCatsEvent();

  @override
  List<Object?> get props => [];
}
