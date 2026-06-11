import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';

class HomeLoadingWidget extends StatefulWidget {
  const HomeLoadingWidget({super.key});

  @override
  State<HomeLoadingWidget> createState() => _HomeLoadingWidgetState();
}

class _HomeLoadingWidgetState extends State<HomeLoadingWidget>
    with SingleTickerProviderStateMixin {
  static const _stepCount = 4;

  static const _gifPaths = [
    'assets/images/Illustrations/loading-scanning.gif',
    'assets/images/Illustrations/loading-fetching.gif',
    'assets/images/Illustrations/loading-analyzing.gif',
    'assets/images/Illustrations/loading-almost-ready.gif',
  ];

  static const _icons = [
    Icons.qr_code_scanner_rounded,
    Icons.cloud_download_rounded,
    Icons.science_rounded,
    Icons.assignment_rounded,
  ];

  int _currentStepIndex = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startStepCycle();
  }

  void _startStepCycle() {
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      if (_currentStepIndex < _stepCount - 1) {
        setState(() {
          _currentStepIndex++;
        });
        _startStepCycle();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = [
      LoadingStep(
        icon: _icons[0],
        title: l10n.homeLoadingStepScanning,
        description: l10n.homeLoadingStepScanningDesc,
        gifPath: _gifPaths[0],
      ),
      LoadingStep(
        icon: _icons[1],
        title: l10n.homeLoadingStepFetching,
        description: l10n.homeLoadingStepFetchingDesc,
        gifPath: _gifPaths[1],
      ),
      LoadingStep(
        icon: _icons[2],
        title: l10n.homeLoadingStepAnalyzing,
        description: l10n.homeLoadingStepAnalyzingDesc,
        gifPath: _gifPaths[2],
      ),
      LoadingStep(
        icon: _icons[3],
        title: l10n.homeLoadingStepPreparing,
        description: l10n.homeLoadingStepPreparingDesc,
        gifPath: _gifPaths[3],
      ),
    ];

    return ColoredBox(
      color: DSColors.tintLavender,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                child: Image.asset(
                  steps[_currentStepIndex].gifPath,
                  key: ValueKey(steps[_currentStepIndex].gifPath),
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: DSDimens.sizeXl),
              IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(_stepCount, (index) {
                    final step = steps[index];
                    final isCompleted = index < _currentStepIndex;
                    final isCurrent = index == _currentStepIndex;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: DSDimens.sizeS),
                      child: Row(
                        children: [
                          _buildStepIndicator(
                            isCompleted: isCompleted,
                            isCurrent: isCurrent,
                            step: step,
                          ),
                          const SizedBox(width: DSDimens.sizeS),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step.title,
                                  style: DSTextStyles.bodyLg.copyWith(
                                    fontWeight: isCurrent
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isCompleted || isCurrent
                                        ? DSColors.inkPrimary
                                        : DSColors.inkTertiary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isCompleted ? l10n.homeLoadingStepDone : step.description,
                                  style: DSTextStyles.caption.copyWith(
                                    color: isCompleted
                                        ? DSColors.accentSuccess
                                        : DSColors.inkSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator({
    required bool isCompleted,
    required bool isCurrent,
    required LoadingStep step,
  }) {
    if (isCompleted) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: DSColors.accentSuccess,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.check_rounded,
          size: 16,
          color: DSColors.inkInverse,
        ),
      );
    }

    if (isCurrent) {
      return FadeTransition(
        opacity: _pulseAnimation,
        child: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: DSColors.surfaceCard,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(step.icon, size: 16, color: DSColors.inkPrimary),
        ),
      );
    }

    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: DSColors.surfaceCardDim,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(step.icon, size: 16, color: DSColors.inkTertiary),
    );
  }
}

class LoadingStep {
  final IconData icon;
  final String title;
  final String description;
  final String gifPath;

  const LoadingStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.gifPath,
  });
}
