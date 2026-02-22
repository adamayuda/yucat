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

class SearchByBarcodeEvent extends HomeEvent {
  final String barcode;

  const SearchByBarcodeEvent({required this.barcode});

  @override
  List<Object?> get props => [barcode];
}

class BarcodeDetectedEvent extends HomeEvent {
  final String barcode;
  final BuildContext context;

  const BarcodeDetectedEvent({required this.barcode, required this.context});

  @override
  List<Object?> get props => [barcode, context];
}

class PaywallDismissedEvent extends HomeEvent {
  final bool purchasedSubscription;

  const PaywallDismissedEvent({required this.purchasedSubscription});

  @override
  List<Object?> get props => [purchasedSubscription];
}

class ResetScannerEvent extends HomeEvent {
  const ResetScannerEvent();

  @override
  List<Object?> get props => [];
}
