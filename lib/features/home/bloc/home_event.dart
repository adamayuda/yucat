import 'package:auto_route/auto_route.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:yucat/features/product/domain/entities/label_target.dart';

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

  /// Device country (ISO 3166-1 alpha-2, e.g. "ES") read from the OS region
  /// locale. Forwarded to the backend to bias product web_search to the user's
  /// market. Null when the device exposes no region.
  final String? countryCode;

  /// Resolved **app** language (ISO 639-1, e.g. "fr") — what the UI is actually
  /// rendering in, which is not necessarily the device language. Forwarded so
  /// the backend can return translated product copy. Null → English.
  final String? locale;

  /// The router *controller* captured before the ScannerPage pops itself.
  /// We must not navigate via the page's BuildContext after the scan resolves
  /// — by then the ScannerPage is unmounted and any `context.router` lookup
  /// throws ("deactivated widget's ancestor is unsafe"). The StackRouter
  /// controller outlives the page, so it stays safe to push onto.
  final StackRouter router;

  /// Size of the encoded upload and how long the client-side downscale took —
  /// reported on `Product Image Captured` so payload size is observable.
  final int? imageBytes;
  final int? prepMs;

  /// Normalised EAN-13 read off the still on-device, when the frame held a
  /// legible barcode. Sent to the backend as an exact cache key and as the
  /// fallback identity for an unreadable pack. Null when none was found.
  final String? gtin;

  /// The symbology that was read (`ean13`, `upcA`, …), for analytics only.
  final String? barcodeFormat;

  /// `camera` or `gallery`.
  final String captureSource;

  const ImageCapturedEvent({
    required this.imageBase64,
    required this.mimeType,
    required this.router,
    required this.captureSource,
    this.countryCode,
    this.locale,
    this.imageBytes,
    this.prepMs,
    this.gtin,
    this.barcodeFormat,
  });

  @override
  List<Object?> get props => [
        imageBase64,
        mimeType,
        router,
        captureSource,
        countryCode,
        locale,
        imageBytes,
        prepMs,
        gtin,
        barcodeFormat,
      ];
}

/// A back-label capture (scan-pipeline Phase 2). Same shape as
/// [ImageCapturedEvent] minus the barcode fields (no barcode is read in label
/// mode) plus the [target] the label's data attaches to.
class LabelImageCapturedEvent extends HomeEvent {
  final String imageBase64;
  final String mimeType;
  final LabelTarget target;
  final StackRouter router;
  final String? countryCode;
  final String? locale;
  final int? imageBytes;
  final int? prepMs;

  const LabelImageCapturedEvent({
    required this.imageBase64,
    required this.mimeType,
    required this.target,
    required this.router,
    this.countryCode,
    this.locale,
    this.imageBytes,
    this.prepMs,
  });

  @override
  List<Object?> get props =>
      [imageBase64, mimeType, target, router, countryCode, locale];
}

/// The user tapped Cancel on the scan theater. The in-flight callable keeps
/// running server-side (and still caches its result); the bloc just drops
/// the response when it arrives and returns Home to its dashboard.
class ScanAbandonedEvent extends HomeEvent {
  const ScanAbandonedEvent();

  @override
  List<Object?> get props => [];
}

class PaywallDismissedEvent extends HomeEvent {
  final bool purchasedSubscription;

  const PaywallDismissedEvent({required this.purchasedSubscription});

  @override
  List<Object?> get props => [purchasedSubscription];
}
