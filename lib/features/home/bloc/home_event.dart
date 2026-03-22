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

class ImageCapturedEvent extends HomeEvent {
  final String imageBase64;
  final String mimeType;
  final BuildContext context;

  const ImageCapturedEvent({
    required this.imageBase64,
    required this.mimeType,
    required this.context,
  });

  @override
  List<Object?> get props => [imageBase64, mimeType, context];
}

class PaywallDismissedEvent extends HomeEvent {
  final bool purchasedSubscription;

  const PaywallDismissedEvent({required this.purchasedSubscription});

  @override
  List<Object?> get props => [purchasedSubscription];
}
