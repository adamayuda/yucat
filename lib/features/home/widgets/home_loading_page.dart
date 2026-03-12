import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class HomeLoadingWidget extends StatefulWidget {
  const HomeLoadingWidget({super.key});

  @override
  State<HomeLoadingWidget> createState() => _HomeLoadingWidgetState();
}

class _HomeLoadingWidgetState extends State<HomeLoadingWidget>
    with SingleTickerProviderStateMixin {
  final List<LoadingStep> _steps = [
    const LoadingStep(
      icon: Icons.qr_code_scanner,
      title: 'Scanning barcode',
      description: 'Reading product code...',
      gifPath: 'assets/images/Illustrations/Scanning barcode_1.gif',
    ),
    const LoadingStep(
      icon: Icons.cloud_download,
      title: 'Fetching product data',
      description: 'Retrieving information...',
      gifPath: 'assets/images/Illustrations/Fetching product data_2.gif',
    ),
    const LoadingStep(
      icon: Icons.science,
      title: 'Analyzing ingredients',
      description: 'Processing nutritional data...',
      gifPath: 'assets/images/Illustrations/Analyzing ingredients_3.gif',
    ),
    const LoadingStep(
      icon: Icons.assignment,
      title: 'Preparing results',
      description: 'Almost ready...',
      gifPath: 'assets/images/Illustrations/Almost ready_4.gif',
    ),
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
      if (_currentStepIndex < _steps.length - 1) {
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
    return ColoredBox(
      color: Colors.white,
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
                  _steps[_currentStepIndex].gifPath,
                  key: ValueKey(_steps[_currentStepIndex].gifPath),
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: DSDimens.sizeXl),
              IntrinsicWidth(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(_steps.length, (index) {
                  final step = _steps[index];
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
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isCurrent
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isCompleted || isCurrent
                                      ? DSColors.darkBlue
                                      : DSColors.darkGrey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isCompleted ? 'Done' : step.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isCompleted
                                      ? DSColors.primary
                                      : DSColors.darkGrey,
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
      return Image.asset(
        'assets/images/Icons/green.png',
        width: 28,
        height: 28,
      );
    }

    if (isCurrent) {
      return FadeTransition(
        opacity: _pulseAnimation,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: DSColors.primarySurface,
            shape: BoxShape.circle,
          ),
          child: Icon(step.icon, size: 16, color: DSColors.primary),
        ),
      );
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: DSColors.inputLightGrey,
        shape: BoxShape.circle,
      ),
      child: Icon(step.icon, size: 16, color: DSColors.darkGrey),
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
