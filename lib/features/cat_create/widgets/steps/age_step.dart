import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoPicker, FixedExtentScrollController;
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

class AgeStep extends StatefulWidget {
  final int? age;
  final ValueChanged<int?> onAgeChanged;

  const AgeStep({super.key, required this.age, required this.onAgeChanged});

  /// Age is stored as a flat month count. The two-column picker splits it into
  /// years (0–[maxYears]) and months (0–11).
  static const int maxYears = 25;

  @override
  State<AgeStep> createState() => _AgeStepState();
}

class _AgeStepState extends State<AgeStep> {
  late FixedExtentScrollController _yearsController;
  late FixedExtentScrollController _monthsController;
  late int _years;
  late int _months;

  @override
  void initState() {
    super.initState();
    final initialMonths = (widget.age ?? 18).clamp(0, AgeStep.maxYears * 12 + 11);
    _years = initialMonths ~/ 12;
    _months = initialMonths % 12;
    _yearsController = FixedExtentScrollController(initialItem: _years);
    _monthsController = FixedExtentScrollController(initialItem: _months);
    if (widget.age == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAgeChanged(_totalMonths);
      });
    }
  }

  int get _totalMonths => _years * 12 + _months;

  @override
  void dispose() {
    _yearsController.dispose();
    _monthsController.dispose();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MascotSpeechBubble(question: 'How old is your cat?'),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: _columnHeader('Years')),
                    Expanded(child: _columnHeader('Months')),
                  ],
                ),
                const SizedBox(height: DSDimens.sizeXs),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // shared selection band behind both wheels
                    Container(
                      height: 56,
                      margin: const EdgeInsets.symmetric(
                        horizontal: DSDimens.sizeL,
                      ),
                      decoration: BoxDecoration(
                        color: DSColors.surfaceCardDim,
                        borderRadius: BorderRadius.circular(DSRadii.lg),
                      ),
                    ),
                    SizedBox(
                      height: 220,
                      child: Row(
                        children: [
                          Expanded(
                            child: _wheel(
                              controller: _yearsController,
                              count: AgeStep.maxYears + 1,
                              current: _years,
                              unit: 'yr',
                              onChanged: (value) {
                                setState(() => _years = value);
                                widget.onAgeChanged(_totalMonths);
                              },
                            ),
                          ),
                          Expanded(
                            child: _wheel(
                              controller: _monthsController,
                              count: 12,
                              current: _months,
                              unit: 'mo',
                              onChanged: (value) {
                                setState(() => _months = value);
                                widget.onAgeChanged(_totalMonths);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                  _stageLabel(_totalMonths),
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

  Widget _columnHeader(String label) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkTertiary),
    );
  }

  Widget _wheel({
    required FixedExtentScrollController controller,
    required int count,
    required int current,
    required String unit,
    required ValueChanged<int> onChanged,
  }) {
    return CupertinoPicker.builder(
      scrollController: controller,
      itemExtent: 56,
      selectionOverlay: const SizedBox.shrink(),
      childCount: count,
      onSelectedItemChanged: onChanged,
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
                  fontSize: isCenter ? 44 : 26,
                  color: isCenter ? DSColors.inkPrimary : DSColors.inkTertiary,
                ),
              ),
              if (isCenter) ...[
                const SizedBox(width: 6),
                Text(
                  unit,
                  style: DSTextStyles.bodyMd.copyWith(
                    color: DSColors.inkSecondary,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
