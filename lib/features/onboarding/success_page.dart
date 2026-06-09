import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/features/cat_create/presentation/models/cat_summary.dart';
import 'package:yucat/features/onboarding/widgets/success_screen.dart';

/// Standalone route wrapping the onboarding [SuccessScreen].
///
/// It is pushed *over* the cat-create wizard when a cat is created during
/// onboarding, so it slides in from the right like any forward step — instead
/// of being revealed by the wizard popping, which read as a backward
/// transition (the success screen appearing "from the left").
@RoutePage()
class SuccessPage extends StatelessWidget {
  /// At-a-glance recap of the cat that was just created.
  final CatSummary? summary;

  /// Invoked (with this page's own context) when the user taps the CTA —
  /// the onboarding flow uses it to finalize (paywall → main).
  final void Function(BuildContext context) onStart;

  const SuccessPage({
    super.key,
    required this.summary,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return SuccessScreen(
      summary: summary,
      onStart: () => onStart(context),
    );
  }
}
