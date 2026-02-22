part of 'onboarding_bloc.dart';

sealed class OnBoardingState extends Equatable {
  const OnBoardingState();
}

class OnBoardingLoadingState extends OnBoardingState {
  @override
  List<Object?> get props => [];
}

class OnBoardingReadyState extends OnBoardingState {
  final int currentPage;

  const OnBoardingReadyState({this.currentPage = 0});

  @override
  List<Object?> get props => [currentPage];
}
