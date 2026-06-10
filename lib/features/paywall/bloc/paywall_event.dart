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

class PaywallRestoreEvent extends PaywallEvent {
  const PaywallRestoreEvent();
}

class PaywallDismissEvent extends PaywallEvent {
  const PaywallDismissEvent();
}

class PaywallPromoToggledEvent extends PaywallEvent {
  final bool promoOn;

  const PaywallPromoToggledEvent({required this.promoOn});

  @override
  List<Object?> get props => [promoOn];
}
