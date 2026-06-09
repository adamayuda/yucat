import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

class WizardStepShell extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Widget child;
  final String ctaLabel;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool isSubmitting;
  final bool ctaEnabled;
  final Color background;

  /// Optional full-screen gradient painted behind the entire step (nav row,
  /// content, and CTA). When set, [background] is used only for the
  /// floating-next fade overlay; the Scaffold itself is transparent.
  final Gradient? backgroundGradient;

  /// Optional widget painted full-screen behind everything (status bar, nav
  /// row, content and CTA) — e.g. a decorative SVG backdrop for a step that
  /// wants to bleed edge-to-edge.
  final Widget? backgroundChild;
  final bool useCloseIcon;

  /// Optional alternate label shown when [hasSelection] is `false`.
  /// Used for skip-style CTAs on multi-select steps (e.g. "None of these").
  final String? altCtaLabel;
  final bool hasSelection;

  /// When true, the Next button floats over the scrolling step content
  /// with a fade gradient instead of sitting in a Column below it.
  /// Use for steps whose content can overflow (long lists, chip wraps).
  final bool floatingNext;

  /// Whether to show the step progress bar next to the back button. Hidden on
  /// non-input interstitials ("did you know" facts), which only show the back
  /// chevron.
  final bool showProgress;

  const WizardStepShell({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.child,
    required this.ctaLabel,
    required this.onNext,
    required this.onBack,
    this.isSubmitting = false,
    this.ctaEnabled = true,
    this.background = DSColors.tintCloud,
    this.backgroundGradient,
    this.backgroundChild,
    this.useCloseIcon = false,
    this.altCtaLabel,
    this.hasSelection = true,
    this.floatingNext = false,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final stepNumber = currentStep + 1;
    final progress = stepNumber / totalSteps;
    final showAlt = !hasSelection && altCtaLabel != null;
    final label = showAlt ? altCtaLabel! : ctaLabel;

    final button = DSPillButton(
      label: label,
      loading: isSubmitting,
      onPressed: (ctaEnabled && !isSubmitting) ? onNext : null,
    );

    // The step content's ancestor chain is kept identical across every step
    // variation: the background (solid vs gradient) and the CTA placement
    // (inline vs floating) are toggled WITHOUT inserting or removing widgets
    // above [child]. If the tree above [child] changed shape per step, the
    // PageView's element would be rebuilt and its PageController would snap
    // back to its initial page — making earlier steps reappear.
    // Only the nav row and CTA are horizontally inset — the step content is
    // full-bleed so steps can paint edge-to-edge (e.g. the water glasses band).
    // Steps that want padded content add it themselves.
    final body = SafeArea(
      child: Column(
        children: [
          const SizedBox(height: DSDimens.sizeXxs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
            child: Row(
              children: [
                _NavIcon(
                  icon: useCloseIcon ? Icons.close : Icons.chevron_left,
                  onTap: onBack,
                ),
                if (showProgress) ...[
                  const SizedBox(width: DSDimens.sizeS),
                  Expanded(child: _ProgressBar(progress: progress)),
                ],
              ],
            ),
          ),
          const SizedBox(height: DSDimens.sizeL),
          Expanded(
            child: Stack(
              children: [
                // Always the first Stack child so its element is stable.
                Positioned.fill(child: child),
                if (floatingNext)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 96,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              background.withValues(alpha: 0),
                              background,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (floatingNext)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: DSDimens.size3xl,
                    child: Center(child: button),
                  ),
              ],
            ),
          ),
          if (!floatingNext)
            Padding(
              padding: const EdgeInsets.only(
                top: DSDimens.sizeS,
                // Match the onboarding CTA level (40px from the safe-area edge).
                bottom: DSDimens.size3xl,
              ),
              child: button,
            ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundGradient == null ? background : null,
          gradient: backgroundGradient,
        ),
        // The Stack is always present (even when [backgroundChild] is null) so
        // the tree shape above the step content stays constant across step
        // rebuilds — otherwise the PageView element would be recreated and snap.
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: backgroundChild ?? const SizedBox.shrink(),
            ),
            SizedBox.expand(child: body),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(DSRadii.pill),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(DSDimens.sizeXxs),
        child: Icon(icon, color: DSColors.inkPrimary, size: 28),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DSRadii.pill),
      child: SizedBox(
        height: 8,
        child: Stack(
          children: [
            Container(color: DSColors.surfaceCard),
            FractionallySizedBox(
              widthFactor: progress.clamp(0, 1),
              child: AnimatedContainer(
                duration: DSMotion.durMed,
                curve: DSMotion.curveStandard,
                color: DSColors.accentSuccess,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
