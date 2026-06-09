import 'package:auto_route/auto_route.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();
}

class HomeInitialEvent extends HomeEvent {
  @override
  List<Object?> get props => [];
}

class SearchEvent extends HomeEvent {
  final String query;
  final BuildContext context;

  const SearchEvent({required this.query, required this.context});

  @override
  List<Object?> get props => [query, context];
}

class ImageCapturedEvent extends HomeEvent {
  final String imageBase64;
  final String mimeType;

  /// The router *controller* captured before the ScannerPage pops itself.
  /// We must not navigate via the page's BuildContext after the scan resolves
  /// — by then the ScannerPage is unmounted and any `context.router` lookup
  /// throws ("deactivated widget's ancestor is unsafe"). The StackRouter
  /// controller outlives the page, so it stays safe to push onto.
  final StackRouter router;

  const ImageCapturedEvent({
    required this.imageBase64,
    required this.mimeType,
    required this.router,
  });

  @override
  List<Object?> get props => [imageBase64, mimeType, router];
}

class PaywallDismissedEvent extends HomeEvent {
  final bool purchasedSubscription;

  const PaywallDismissedEvent({required this.purchasedSubscription});

  @override
  List<Object?> get props => [purchasedSubscription];
}
