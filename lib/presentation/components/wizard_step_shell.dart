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
  final bool useCloseIcon;

  /// Optional alternate label shown when [hasSelection] is `false`.
  /// Used for skip-style CTAs on multi-select steps (e.g. "None of these").
  final String? altCtaLabel;
  final bool hasSelection;

  /// When true, the Next button floats over the scrolling step content
  /// with a fade gradient instead of sitting in a Column below it.
  /// Use for steps whose content can overflow (long lists, chip wraps).
  final bool floatingNext;

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
    this.background = DSColors.tintLavender,
    this.useCloseIcon = false,
    this.altCtaLabel,
    this.hasSelection = true,
    this.floatingNext = false,
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

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
          child: Column(
            children: [
              const SizedBox(height: DSDimens.sizeXxs),
              Row(
                children: [
                  _NavIcon(
                    icon: useCloseIcon ? Icons.close : Icons.chevron_left,
                    onTap: onBack,
                  ),
                  const SizedBox(width: DSDimens.sizeS),
                  Expanded(child: _ProgressBar(progress: progress)),
                ],
              ),
              const SizedBox(height: DSDimens.sizeL),
              Expanded(
                child: floatingNext
                    ? _FloatingNextLayout(
                        background: background,
                        button: button,
                        child: child,
                      )
                    : child,
              ),
              if (!floatingNext)
                Padding(
                  padding: const EdgeInsets.only(
                    top: DSDimens.sizeS,
                    bottom: DSDimens.sizeS,
                  ),
                  child: button,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingNextLayout extends StatelessWidget {
  final Color background;
  final Widget button;
  final Widget child;

  const _FloatingNextLayout({
    required this.background,
    required this.button,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
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
        Positioned(
          left: 0,
          right: 0,
          bottom: DSDimens.sizeS,
          child: Center(child: button),
        ),
      ],
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
