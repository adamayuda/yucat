import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

class BreedStep extends StatefulWidget {
  final String? selectedBreed;
  final List<String> breeds;
  final ValueChanged<String> onBreedSelected;

  const BreedStep({
    super.key,
    required this.selectedBreed,
    required this.breeds,
    required this.onBreedSelected,
  });

  @override
  State<BreedStep> createState() => _BreedStepState();
}

class _BreedStepState extends State<BreedStep> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredBreeds {
    List<String> filtered;
    if (_searchQuery.isEmpty) {
      filtered = List.from(widget.breeds);
    } else {
      filtered = widget.breeds
          .where((breed) => breed.toLowerCase().contains(_searchQuery))
          .toList();
    }

    if (filtered.contains('Other')) {
      filtered.remove('Other');
      filtered.insert(0, 'Other');
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final breeds = _filteredBreeds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MascotSpeechBubble(
          question: 'What breed is your cat?',
        ),
        const SizedBox(height: DSDimens.sizeL),
        TextField(
          controller: _searchController,
          cursorColor: DSColors.inkPrimary,
          style: DSTextStyles.bodyLg,
          decoration: InputDecoration(
            hintText: 'Search breeds…',
            hintStyle: DSTextStyles.bodyLg.copyWith(
              color: DSColors.inkTertiary,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: DSColors.inkTertiary,
            ),
            filled: true,
            fillColor: DSColors.surfaceCard,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: DSDimens.sizeS,
              vertical: DSDimens.sizeS,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DSRadii.lg),
              borderSide: BorderSide(color: DSColors.surfaceCardDim),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DSRadii.lg),
              borderSide: const BorderSide(
                color: DSColors.inkPrimary,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: DSDimens.sizeS),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: breeds.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: DSDimens.sizeXs),
            itemBuilder: (context, index) {
              final breed = breeds[index];
              return DSOptionRow(
                label: breed,
                selected: widget.selectedBreed == breed,
                onTap: () => widget.onBreedSelected(breed),
              );
            },
          ),
        ),
      ],
    );
  }
}
