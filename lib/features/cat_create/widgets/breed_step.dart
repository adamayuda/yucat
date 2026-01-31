import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

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

    // Ensure "Other" is always first
    if (filtered.contains('Other')) {
      filtered.remove('Other');
      filtered.insert(0, 'Other');
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E8FF),
                  borderRadius: BorderRadius.circular(DSDimens.sizeXxs),
                ),
                width: 40,
                height: 40,
                child: Image.asset(
                  'assets/images/breed.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: DSDimens.sizeS),
              Expanded(
                child: Text(
                  'What breed is your cat?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: DSDimens.sizeS),
          TextField(
            controller: _searchController,
            style: const TextStyle(
              color: Color(0xFFA0A8B6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Search breeds...',
              hintStyle: const TextStyle(
                color: Color(0xFFA0A8B6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: DSColors.white,
              contentPadding: const EdgeInsets.only(
                left: 24,
                top: 16,
                bottom: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DSDimens.sizeXs),
                borderSide: const BorderSide(color: Color(0xFFE6E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DSDimens.sizeXs),
                borderSide: const BorderSide(color: Color(0xFFFF61E5)),
              ),
            ),
          ),
          SizedBox(height: DSDimens.sizeS),
          Column(
            children: _filteredBreeds.map((breed) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () => widget.onBreedSelected(breed),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: widget.selectedBreed == breed
                          ? const Color(0xFFFEF5FE)
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      breed,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF334156),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
