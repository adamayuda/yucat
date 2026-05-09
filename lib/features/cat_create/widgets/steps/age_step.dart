import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

class AgeStep extends StatelessWidget {
  final int? age;
  final ValueChanged<int?> onAgeChanged;

  const AgeStep({super.key, required this.age, required this.onAgeChanged});

  static const int _minMonths = 0;
  static const int _maxMonths = 240;

  String _formatAge(int months) {
    if (months <= 0) return 'Newborn';
    if (months < 12) {
      return months == 1 ? '1 month' : '$months months';
    }
    final years = months ~/ 12;
    final remainder = months % 12;
    final yearLabel = years == 1 ? '1 yr' : '$years yr';
    if (remainder == 0) return yearLabel;
    return '$yearLabel ${remainder == 1 ? '1 mo' : '$remainder mo'}';
  }

  @override
  Widget build(BuildContext context) {
    final value = (age ?? 0).clamp(_minMonths, _maxMonths).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MascotSpeechBubble(
          question: 'How old is your cat?',
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Age',
                  style: DSTextStyles.bodyLg.copyWith(
                    color: DSColors.inkTertiary,
                  ),
                ),
                const SizedBox(height: DSDimens.sizeXxs),
                Text(
                  _formatAge(value.round()),
                  style: DSTextStyles.displayLg,
                ),
                const SizedBox(height: DSDimens.sizeM),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: DSColors.coralAccent,
                    inactiveTrackColor: DSColors.inputLightGrey,
                    thumbColor: DSColors.coralAccent,
                    overlayColor: DSColors.coralAccent.withValues(alpha: 0.15),
                    trackHeight: 4,
                    showValueIndicator: ShowValueIndicator.never,
                  ),
                  child: Slider(
                    min: _minMonths.toDouble(),
                    max: _maxMonths.toDouble(),
                    divisions: _maxMonths,
                    value: value,
                    onChanged: (v) => onAgeChanged(v.round()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSDimens.sizeS,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kitten',
                        style: DSTextStyles.caption,
                      ),
                      Text(
                        'Adult',
                        style: DSTextStyles.caption,
                      ),
                      Text(
                        'Senior',
                        style: DSTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
