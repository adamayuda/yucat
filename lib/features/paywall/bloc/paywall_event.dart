import 'package:equatable/equatable.dart';

sealed class PaywallEvent extends Equatable {
  const PaywallEvent();

  @override
  List<Object?> get props => [];
}

class PaywallInitialEvent extends PaywallEvent {
  const PaywallInitialEvent();
}
