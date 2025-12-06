import 'package:equatable/equatable.dart';

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
  const ProfileLoadedState();

  @override
  List<Object?> get props => [];
}

class ProfileErrorState extends ProfileState {
  @override
  List<Object?> get props => [];
}
