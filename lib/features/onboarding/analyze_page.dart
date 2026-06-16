import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/features/cat_create/presentation/models/cat_summary.dart';
import 'package:yucat/features/onboarding/widgets/analyze_screen.dart';

/// The "analyzing your cat" loading beat, pushed over the wizard right after a
/// cat is created. It generates the personalized narrative, then `replace`s
/// itself with the result screen (so Back from the result never returns here).
@RoutePage()
class AnalyzePage extends StatelessWidget {
  /// Recap of the cat just created (carries the canonical [CatSummary.entity]).
  final CatSummary summary;

  /// Forwarded to the result screen's CTA — finalizes onboarding (paywall).
  final void Function(BuildContext context) onStart;

  const AnalyzePage({
    super.key,
    required this.summary,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return AnalyzeScreen(
      entity: summary.entity,
      onDone: (result) {
        context.router.replace(
          ResultRoute(
            summary: summary,
            narrative: result,
            onStart: onStart,
          ),
        );
      },
    );
  }
}
