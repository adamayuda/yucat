part of 'food_guide_bloc.dart';

sealed class FoodGuideEvent extends Equatable {
  const FoodGuideEvent();

  @override
  List<Object?> get props => [];
}

class FoodGuideInitialEvent extends FoodGuideEvent {
  /// The app's resolved language code. Null or unsupported yields the
  /// canonical English copy.
  final String? language;

  const FoodGuideInitialEvent({this.language});

  @override
  List<Object?> get props => [language];
}
