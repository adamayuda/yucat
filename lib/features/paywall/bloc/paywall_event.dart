import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

sealed class PaywallEvent extends Equatable {
  const PaywallEvent();

  @override
  List<Object?> get props => [];
}

class PaywallInitialEvent extends PaywallEvent {
  /// Where the paywall was opened from, e.g. `onboarding_complete` or
  /// `returning_user`. Stamped onto all paywall funnel events.
  final String trigger;

  const PaywallInitialEvent({this.trigger = 'manual'});

  @override
  List<Object?> get props => [trigger];
}

class PaywallPackageSelectedEvent extends PaywallEvent {
  final Package package;

  const PaywallPackageSelectedEvent({required this.package});

  @override
  List<Object?> get props => [package.identifier];
}

class PaywallPurchaseEvent extends PaywallEvent {
  const PaywallPurchaseEvent();
}

/// The user took the cheaper plan on the second-chance sheet. One event for
/// "select the monthly package, then buy it" rather than two, because bloc
/// handlers run concurrently by default and a purchase must never race the
/// selection it depends on.
class PaywallSecondChanceAcceptedEvent extends PaywallEvent {
  const PaywallSecondChanceAcceptedEvent();
}

/// The user closed the second-chance sheet without taking the offer.
/// Analytics only — the paywall stays exactly as it was.
class PaywallSecondChanceDismissedEvent extends PaywallEvent {
  const PaywallSecondChanceDismissedEvent();
}

class PaywallRestoreEvent extends PaywallEvent {
  const PaywallRestoreEvent();
}

class PaywallDismissEvent extends PaywallEvent {
  const PaywallDismissEvent();
}
