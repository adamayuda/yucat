part of 'splash_bloc.dart';

sealed class SplashState extends Equatable {
  const SplashState();
}

class SplashLoadingState extends SplashState {
  @override
  List<Object?> get props => [];
}
