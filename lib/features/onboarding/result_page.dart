import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/features/cat/domain/entities/cat_narrative.dart';
import 'package:yucat/features/cat_create/presentation/models/cat_summary.dart';
import 'package:yucat/features/onboarding/widgets/result_screen.dart';

/// The personalized result reveal, shown after the analyze beat. Receives the
/// already-generated [narrative]; its CTA continues to the brand step (which
/// then finalizes onboarding → paywall) via [onStart].
@RoutePage()
class ResultPage extends StatelessWidget {
  final CatSummary summary;
  final CatNarrative? narrative;
  final void Function(BuildContext context) onStart;

  const ResultPage({
    super.key,
    required this.summary,
    required this.narrative,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return ResultScreen(
      summary: summary,
      narrative: narrative,
      onStart: onStart,
    );
  }
}
