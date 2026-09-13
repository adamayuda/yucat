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

  /// Carnet summaries keyed by cat id. A cat missing from the map had a
  /// failed read (or no id) and shows no pill — never a "set up" nudge.
  final Map<String, CatHealthSummary> health;

  const CatListingLoadedState({
    required this.cats,
    this.health = const {},
  });

  @override
  List<Object?> get props => [
        cats,
        health.keys.toList(),
        health.values
            .map((h) => '${h.nearest?.protocol.id}:${h.nearest?.dueDate}')
            .toList(),
      ];
}

class CatListingErrorState extends CatListingState {
  final String message;

  const CatListingErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class CatListingShowPaywallState extends CatListingState {
  const CatListingShowPaywallState();

  @override
  List<Object?> get props => [];
}

class CatListingEmptyState extends CatListingState {
  const CatListingEmptyState();

  @override
  List<Object?> get props => [];
}
