import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoPicker, FixedExtentScrollController;
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

class AgeStep extends StatefulWidget {
  final int? age;
  final ValueChanged<int?> onAgeChanged;

  const AgeStep({super.key, required this.age, required this.onAgeChanged});

  static const int minMonths = 0;
  static const int maxMonths = 240;

  @override
  State<AgeStep> createState() => _AgeStepState();
}

class _AgeStepState extends State<AgeStep> {
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    final initial = (widget.age ?? 18).clamp(
      AgeStep.minMonths,
      AgeStep.maxMonths,
    );
    _controller = FixedExtentScrollController(initialItem: initial);
    if (widget.age == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAgeChanged(initial);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _stageLabel(int months) {
    if (months < 12) {
      final years = (months / 12).toStringAsFixed(1);
      return 'About $years years old — a kitten.';
    }
    if (months < 84) {
      final years = (months / 12).toStringAsFixed(1);
      return 'About $years years old — an adult.';
    }
    final years = (months / 12).toStringAsFixed(1);
    return 'About $years years old — a senior.';
  }

  @override
  Widget build(BuildContext context) {
    final current = (widget.age ?? 18).clamp(
      AgeStep.minMonths,
      AgeStep.maxMonths,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MascotSpeechBubble(question: 'How old is your cat?'),
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // selection band
                Container(
                  height: 56,
                  margin: const EdgeInsets.symmetric(
                    horizontal: DSDimens.size3xl,
                  ),
                  decoration: BoxDecoration(
                    color: DSColors.surfaceCardDim,
                    borderRadius: BorderRadius.circular(DSRadii.lg),
                  ),
                ),
                SizedBox(
                  height: 220,
                  child: CupertinoPicker.builder(
                    scrollController: _controller,
                    itemExtent: 56,
                    selectionOverlay: const SizedBox.shrink(),
                    childCount: AgeStep.maxMonths + 1,
                    onSelectedItemChanged: (index) =>
                        widget.onAgeChanged(index),
                    itemBuilder: (context, index) {
                      final isCenter = index == current;
                      return Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$index',
                              style: DSTextStyles.displayHero.copyWith(
                                fontSize: isCenter ? 48 : 28,
                                color: isCenter
                                    ? DSColors.inkPrimary
                                    : DSColors.inkTertiary,
                              ),
                            ),
                            if (isCenter) ...[
                              const SizedBox(width: 6),
                              Text(
                                'mo',
                                style: DSTextStyles.bodyMd.copyWith(
                                  color: DSColors.inkSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
          padding: const EdgeInsets.all(DSDimens.sizeS),
          decoration: BoxDecoration(
            color: DSColors.surfaceCardDim,
            borderRadius: BorderRadius.circular(DSRadii.md),
          ),
          child: Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: DSDimens.sizeXxs),
              Expanded(
                child: Text(
                  _stageLabel(current),
                  style: DSTextStyles.bodyMd,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DSDimens.sizeS),
      ],
    );
  }
}
