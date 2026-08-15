import 'package:equatable/equatable.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();
}

class ProfileLoadingState extends ProfileState {
  @override
  List<Object?> get props => [];
}

class ProfileHiddenState extends ProfileState {
  @override
  List<Object?> get props => [];
}

class ProfileLoadedState extends ProfileState {
  /// The user's cats, for the compact "Your cats" section.
  final List<CatEntity> cats;

  /// Saved products and scan history (newest-first) for the library preview
  /// rows — drive the counts and recent cover thumbnails.
  final List<ProductDisplayModel> savedProducts;
  final List<LitterDisplayModel> savedLitters;
  final List<ProductDisplayModel> scanHistory;
  final List<LitterDisplayModel> litterHistory;

  const ProfileLoadedState({
    this.cats = const [],
    this.savedProducts = const [],
    this.savedLitters = const [],
    this.scanHistory = const [],
    this.litterHistory = const [],
  });

  @override
  List<Object?> get props =>
      [cats, savedProducts, savedLitters, scanHistory, litterHistory];
}

class ProfileErrorState extends ProfileState {
  @override
  List<Object?> get props => [];
}
