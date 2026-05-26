import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

const _mixedBreedValue = 'Other';

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
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Real breeds (everything except "Other") alphabetized; "Other" surfaces
  /// as a separate "Mixed / unknown" affordance below the list.
  List<String> get _alphabetized {
    final breeds = widget.breeds
        .where((b) => b != _mixedBreedValue)
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return breeds;
  }

  List<String> get _filtered {
    if (_query.isEmpty) return _alphabetized;
    final q = _query.toLowerCase();
    return _alphabetized.where((b) => b.toLowerCase().contains(q)).toList();
  }

  Map<String, List<String>> _grouped(List<String> breeds) {
    final groups = <String, List<String>>{};
    for (final breed in breeds) {
      final letter = breed[0].toUpperCase();
      groups.putIfAbsent(letter, () => []).add(breed);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final groups = _grouped(filtered);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MascotSpeechBubble(question: 'What breed is your cat?'),
        const SizedBox(height: DSDimens.sizeS),
        _SearchField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: DSDimens.sizeS),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'No breeds match "$_query"',
                    style: DSTextStyles.bodyMd.copyWith(
                      color: DSColors.inkSecondary,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.only(bottom: 96),
                  children: [
                    for (final letter in groups.keys) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DSDimens.sizeXs,
                          vertical: DSDimens.sizeXxs,
                        ),
                        child: Text(
                          letter,
                          style: DSTextStyles.caption.copyWith(
                            color: DSColors.inkTertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      for (final breed in groups[letter]!) ...[
                        DSOptionRow(
                          label: breed,
                          selected: widget.selectedBreed == breed,
                          onTap: () => widget.onBreedSelected(breed),
                        ),
                        const SizedBox(height: DSDimens.sizeXxs),
                      ],
                    ],
                    const SizedBox(height: DSDimens.sizeS),
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            widget.onBreedSelected(_mixedBreedValue),
                        child: Text.rich(
                          TextSpan(
                            text: "Don't know the breed? ",
                            style: DSTextStyles.bodyMd.copyWith(
                              color: DSColors.inkSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: 'Mixed / unknown',
                                style: DSTextStyles.bodyMd.copyWith(
                                  color: DSColors.inkPrimary,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.lg),
        boxShadow: DSShadows.e1,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: DSTextStyles.bodyLg,
        decoration: InputDecoration(
          hintText: 'Search 24 breeds',
          hintStyle: DSTextStyles.bodyLg.copyWith(
            color: DSColors.inkTertiary,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: DSColors.inkTertiary,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: DSDimens.sizeS,
            vertical: DSDimens.sizeXs,
          ),
        ),
      ),
    );
  }
}
