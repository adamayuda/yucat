import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/domain/entities/cat_narrative.dart';
import 'package:yucat/features/cat/domain/repositories/cat_narrative_repository.dart';
import 'package:yucat/features/cat/domain/usecases/generate_cat_narrative_usecase.dart';
import 'package:yucat/features/cat/presentation/utils/cat_diet_recommendations.dart';
import 'package:yucat/features/cat/presentation/utils/cat_product_recommendations.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/mascot_illustration.dart';
import 'package:yucat/service_locator.dart';

/// The "analyzing your cat" beat between the wizard and the result reveal.
///
/// Plays a staged, mascot-led loading sequence while it actually generates the
/// personalized narrative (so the wait is purposeful, not theatre). When both
/// the generation and a minimum display time have elapsed, [onDone] fires with
/// the result (null → the result screen shows its local fallback).
class AnalyzeScreen extends StatefulWidget {
  final CatEntity entity;
  final void Function(CatNarrative? result) onDone;

  const AnalyzeScreen({
    super.key,
    required this.entity,
    required this.onDone,
  });

  /// Floor on how long the loader shows, so it always feels substantial even
  /// when the backend is fast.
  static const _minDuration = Duration(milliseconds: 8500);
  static const _perStep = Duration(milliseconds: 2000);

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  bool _started = false;
  int _stepIndex = 0;
  bool _done = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _advanceSteps();
    _run();
  }

  void _advanceSteps() {
    Future.delayed(AnalyzeScreen._perStep, () {
      if (!mounted) return;
      // Stop at the last step; it holds until generation completes.
      if (_stepIndex < _steps(AppLocalizations.of(context)).length - 1) {
        setState(() => _stepIndex++);
        _advanceSteps();
      }
    });
  }

  Future<void> _run() async {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final tips = recommendDiet(widget.entity, l10n);

    final stopwatch = Stopwatch()..start();

    Future<CatNarrative?> fetch() async {
      try {
        return await sl<GenerateCatNarrativeUsecase>()
            .call(
              cat: widget.entity,
              tips: [
                for (final r in tips)
                  DietTip(
                      nutrient: r.nutrient.name, direction: r.direction.name),
              ],
              locale: locale,
            )
            .timeout(const Duration(seconds: 8));
      } catch (_) {
        return null;
      }
    }

    final results = await Future.wait([
      fetch(),
      // Warm the per-cat picks cache so the brand step's locked teaser is
      // instant; the result is discarded here.
      recommendProductsForCat(widget.entity, l10n, limit: 3),
      Future<void>.delayed(AnalyzeScreen._minDuration),
    ]);
    stopwatch.stop();
    final result = results[0] as CatNarrative?;

    sl<LogEventUsecase>().call(
      eventName: 'Cat Narrative Shown',
      properties: {
        'source': result != null ? 'llm' : 'fallback',
        'has_outlook': result?.outlook != null,
        'latency_ms': stopwatch.elapsedMilliseconds,
        'tip_count': tips.length,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    if (!mounted || _done) return;
    _done = true;
    widget.onDone(result);
  }

  List<String> _steps(AppLocalizations l10n) => [
        l10n.onboardingAnalyzeStep1(widget.entity.name),
        l10n.onboardingAnalyzeStep2,
        l10n.onboardingAnalyzeStep3,
        l10n.onboardingAnalyzeStep4,
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = _steps(l10n);
    final message = steps[_stepIndex % steps.length];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: DSGradients.onboardingHealthIntro,
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MascotIllustration(
                    mascotAsset: 'assets/images/cat-rating.svg',
                    tint: DSColors.tintLavender,
                    size: 200,
                  ),
                  const SizedBox(height: DSDimens.size3xl),
                  Text(
                    l10n.onboardingAnalyzeEyebrow,
                    textAlign: TextAlign.center,
                    style: DSTextStyles.label
                        .copyWith(color: DSColors.inkSecondary),
                  ),
                  const SizedBox(height: DSDimens.sizeXxs),
                  AnimatedSwitcher(
                    duration: DSMotion.durMed,
                    switchInCurve: DSMotion.curveDecelerate,
                    switchOutCurve: DSMotion.curveDecelerate,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.25),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: Text(
                      message,
                      key: ValueKey(message),
                      textAlign: TextAlign.center,
                      style: DSTextStyles.displayLg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
