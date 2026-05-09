import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

class NeuteredStatusStep extends StatelessWidget {
  /// One of: "intact", "neutered", "pregnant", "lactating"
  final String? status;
  final ValueChanged<String?> onStatusChanged;

  static const List<({String label, String value, String emoji})> _options = [
    (label: 'Intact', value: 'intact', emoji: '🐱'),
    (label: 'Neutered / Spayed', value: 'neutered', emoji: '✂️'),
    (label: 'Pregnant', value: 'pregnant', emoji: '🤰'),
    (label: 'Lactating', value: 'lactating', emoji: '🍼'),
  ];

  const NeuteredStatusStep({
    super.key,
    required this.status,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MascotSpeechBubble(
          question: 'Is your cat neutered?',
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in _options) ...[
                  DSOptionRow(
                    label: option.label,
                    leadingEmoji: option.emoji,
                    selected: status == option.value,
                    onTap: () => onStatusChanged(option.value),
                  ),
                  const SizedBox(height: DSDimens.sizeXs),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
