import 'package:equatable/equatable.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';

sealed class HomeState extends Equatable {
  const HomeState();
}

class HomeLoadingState extends HomeState {
  const HomeLoadingState();

  @override
  List<Object?> get props => [];
}

class HomeHiddenState extends HomeState {
  @override
  List<Object?> get props => [];
}

class HomeLoadedState extends HomeState {
  final int _timestamp;

  /// Whether the user has an active premium subscription.
  final bool isPremium;

  /// Primary cat profile (the user's first cat) for the greeting card.
  final String? primaryCatName;
  final String? primaryCatPhotoUrl;

  /// Current scan-day streak. 0 when broken or never started.
  final int currentStreak;

  HomeLoadedState({
    this.isPremium = false,
    this.primaryCatName,
    this.primaryCatPhotoUrl,
    this.currentStreak = 0,
  }) : _timestamp = DateTime.now().microsecondsSinceEpoch;

  @override
  List<Object?> get props => [
        _timestamp,
        isPremium,
        primaryCatName,
        primaryCatPhotoUrl,
        currentStreak,
      ];
}

class HomeErrorState extends HomeState {
  final String message;

  const HomeErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class HomeNavigateToProductDetailState extends HomeState {
  final ProductDisplayModel product;

  const HomeNavigateToProductDetailState({required this.product});

  @override
  List<Object?> get props => [product];
}
