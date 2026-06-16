import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/features/cat_create/presentation/models/cat_summary.dart';
import 'package:yucat/features/onboarding/widgets/current_food_screen.dart';

/// Onboarding "current food" step, pushed from the result screen. Scans the
/// cat's current food, critiques it, teases the locked better-picks, then
/// finalizes onboarding (→ paywall) via [onStart].
@RoutePage()
class CurrentFoodPage extends StatelessWidget {
  final CatSummary summary;
  final void Function(BuildContext context) onStart;

  const CurrentFoodPage({
    super.key,
    required this.summary,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return CurrentFoodScreen(
      summary: summary,
      onStart: () => onStart(context),
    );
  }
}
