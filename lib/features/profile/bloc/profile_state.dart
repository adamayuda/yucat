import 'package:equatable/equatable.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';

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
  final List<ProductDisplayModel> scanHistory;

  const ProfileLoadedState({
    this.cats = const [],
    this.savedProducts = const [],
    this.scanHistory = const [],
  });

  @override
  List<Object?> get props => [cats, savedProducts, scanHistory];
}

class ProfileErrorState extends ProfileState {
  @override
  List<Object?> get props => [];
}
