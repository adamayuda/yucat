import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

class NeuteredStatusStep extends StatelessWidget {
  /// One of: "intact", "neutered", "pregnant", "lactating"
  final String? status;
  final String? gender;
  final ValueChanged<String?> onStatusChanged;

  static const List<
      ({String label, String value, String? asset, String? emoji})>
      _baseOptions = [
    (
      label: 'Intact',
      value: 'intact',
      asset: 'assets/images/Male.svg',
      emoji: null,
    ),
    (
      label: 'Neutered / Spayed',
      value: 'neutered',
      asset: 'assets/images/Beauty.svg',
      emoji: null,
    ),
  ];

  static const List<
      ({String label, String value, String? asset, String? emoji})>
      _femaleOnlyOptions = [
    // No matching icon for "pregnant" yet — falls back to its emoji.
    (label: 'Pregnant', value: 'pregnant', asset: null, emoji: '🤰'),
    (
      label: 'Lactating',
      value: 'lactating',
      asset: 'assets/images/Baby.svg',
      emoji: null,
    ),
  ];

  const NeuteredStatusStep({
    super.key,
    required this.status,
    required this.gender,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      ..._baseOptions,
      if (gender == 'female') ..._femaleOnlyOptions,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MascotSpeechBubble(question: 'Is your cat neutered or spayed?'),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in options) ...[
                  DSOptionRow(
                    label: option.label,
                    leadingAsset: option.asset,
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
