part of 'onboarding_bloc.dart';

sealed class OnBoardingState extends Equatable {
  const OnBoardingState();
}

class OnBoardingLoadingState extends OnBoardingState {
  @override
  List<Object?> get props => [];
}

class OnBoardingReadyState extends OnBoardingState {
  @override
  List<Object?> get props => [];
}
