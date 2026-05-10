import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

class BreedStep extends StatelessWidget {
  final String? selectedBreed;
  final List<String> breeds;
  final ValueChanged<String> onBreedSelected;

  const BreedStep({
    super.key,
    required this.selectedBreed,
    required this.breeds,
    required this.onBreedSelected,
  });

  List<String> get _orderedBreeds {
    final ordered = List<String>.from(breeds);
    if (ordered.remove('Other')) {
      ordered.insert(0, 'Other');
    }
    return ordered;
  }

  @override
  Widget build(BuildContext context) {
    final ordered = _orderedBreeds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MascotSpeechBubble(
          question: 'What breed is your cat?',
        ),
        const SizedBox(height: DSDimens.sizeL),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: ordered.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: DSDimens.sizeXs),
            itemBuilder: (context, index) {
              final breed = ordered[index];
              return DSOptionRow(
                label: breed,
                selected: selectedBreed == breed,
                onTap: () => onBreedSelected(breed),
              );
            },
          ),
        ),
      ],
    );
  }
}
