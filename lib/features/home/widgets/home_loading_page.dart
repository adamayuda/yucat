import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class HomeLoadingWidget extends StatefulWidget {
  const HomeLoadingWidget({super.key});

  @override
  State<HomeLoadingWidget> createState() => _HomeLoadingWidgetState();
}

class _HomeLoadingWidgetState extends State<HomeLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  final List<LoadingStep> _steps = [
    const LoadingStep(
      icon: Icons.qr_code_scanner,
      title: 'Scanning barcode',
      description: 'Reading product code...',
    ),
    const LoadingStep(
      icon: Icons.cloud_download,
      title: 'Fetching product data',
      description: 'Retrieving information...',
    ),
    const LoadingStep(
      icon: Icons.science,
      title: 'Analyzing ingredients',
      description: 'Processing nutritional data...',
    ),
    const LoadingStep(
      icon: Icons.assignment,
      title: 'Preparing results',
      description: 'Almost ready...',
    ),
  ];

  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _startStepCycle();
  }

  void _startStepCycle() {
    Future.delayed(const Duration(milliseconds: 5000), () {
      if (!mounted) return;
      if (_currentStepIndex < _steps.length - 1) {
        setState(() {
          _currentStepIndex = _currentStepIndex + 1;
        });
        _fadeController.reset();
        _fadeController.forward();
        _startStepCycle();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _steps[_currentStepIndex];
    final progress = (_currentStepIndex + 1) / _steps.length;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DSDimens.sizeL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon with pulse effect
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: DSColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  currentStep.icon,
                  size: 60,
                  color: DSColors.primary,
                ),
              ),
            ),
            const SizedBox(height: DSDimens.sizeXl),
            // Step title with fade animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                currentStep.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: DSColors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: DSDimens.sizeXs),
            // Step description with fade animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                currentStep.description,
                style: const TextStyle(fontSize: 16, color: DSColors.darkGrey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: DSDimens.sizeXl),
            // Progress indicator
            SizedBox(
              width: 200,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(DSDimens.sizeXs),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: DSColors.inputLightGrey,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        DSColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: DSDimens.sizeXs),
                  Text(
                    '${(_currentStepIndex + 1)} of ${_steps.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: DSColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DSDimens.sizeXl),
            // Step indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _steps.length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: index == _currentStepIndex ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index <= _currentStepIndex
                          ? DSColors.primary
                          : DSColors.inputLightGrey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingStep {
  final IconData icon;
  final String title;
  final String description;

  const LoadingStep({
    required this.icon,
    required this.title,
    required this.description,
  });
}
