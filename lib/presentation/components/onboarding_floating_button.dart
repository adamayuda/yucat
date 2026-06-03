import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

/// Shared bottom-anchored CTA used across the onboarding survey screens
/// (scan demo, attribution, proof chart).
///
/// Place it as the LAST child of a screen's content column: a preceding
/// `Spacer`/`Expanded` pushes it to the bottom, and the built-in bottom
/// margin gives a consistent gap above the safe-area edge so the button
/// sits at the same height on every screen.
class OnboardingFloatingButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool showChevron;

  const OnboardingFloatingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: DSDimens.sizeS,
        bottom: DSDimens.size3xl,
      ),
      child: DSPillButton(
        label: label,
        onPressed: onPressed,
        showChevron: showChevron,
      ),
    );
  }
}
