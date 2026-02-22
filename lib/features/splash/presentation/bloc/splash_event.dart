part of 'splash_bloc.dart';

sealed class SplashEvent extends Equatable {
  const SplashEvent();
}

class SplashInitialEvent extends SplashEvent {
  final BuildContext context;

  const SplashInitialEvent({required this.context});

  @override
  List<Object?> get props => [context];
}
