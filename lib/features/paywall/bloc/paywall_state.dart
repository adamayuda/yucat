import 'package:equatable/equatable.dart';

sealed class PaywallState extends Equatable {
  const PaywallState();

  @override
  List<Object?> get props => [];
}

class PaywallInitialState extends PaywallState {
  const PaywallInitialState();
}

class PaywallLoadingState extends PaywallState {
  const PaywallLoadingState();
}

class PaywallLoadedState extends PaywallState {
  const PaywallLoadedState();
}

class PaywallSuccessState extends PaywallState {
  final bool purchasedSubscription;

  const PaywallSuccessState({required this.purchasedSubscription});

  @override
  List<Object?> get props => [purchasedSubscription];
}

class PaywallErrorState extends PaywallState {
  final String message;

  const PaywallErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class PaywallAlreadySubscribedState extends PaywallState {
  const PaywallAlreadySubscribedState();
}
