import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/features/cat_create/presentation/models/cat_summary.dart';
import 'package:yucat/features/onboarding/widgets/result_screen.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';

/// The onboarding success reveal, shown after the scan step. Receives the
/// scanned product (or null if skipped); its CTA finalizes onboarding (paywall →
/// main) via [onStart].
@RoutePage()
class ResultPage extends StatelessWidget {
  final CatSummary summary;
  final ProductDisplayModel? scannedProduct;
  final void Function(BuildContext context) onStart;

  const ResultPage({
    super.key,
    required this.summary,
    this.scannedProduct,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return ResultScreen(
      summary: summary,
      scannedProduct: scannedProduct,
      onStart: onStart,
    );
  }
}
