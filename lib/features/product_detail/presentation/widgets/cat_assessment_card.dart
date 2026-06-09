import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/widgets/cat_verdict_card.dart';
import 'package:yucat/presentation/components/cat_avatar.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

class CatAssessmentSection extends StatefulWidget {
  final List<CatEntity> cats;
  final ProductDisplayModel product;
  final VoidCallback onCreateCat;

  const CatAssessmentSection({
    super.key,
    required this.cats,
    required this.product,
    required this.onCreateCat,
  });

  @override
  State<CatAssessmentSection> createState() => _CatAssessmentSectionState();
}

class _CatAssessmentSectionState extends State<CatAssessmentSection> {
  int _selectedIndex = 0;

  @override
  void didUpdateWidget(covariant CatAssessmentSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cats can be re-fetched (e.g. after creating one); keep the selection in
    // range rather than crashing on a stale index.
    if (_selectedIndex >= widget.cats.length) {
      _selectedIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cats = widget.cats;
    if (cats.isEmpty) {
      return DSCard(
        padding: const EdgeInsets.all(DSDimens.sizeL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("My cat's score", style: DSTextStyles.titleMd),
            const SizedBox(height: DSDimens.sizeXxs),
            Text(
              'Create a cat profile to see a personalized score for your cat.',
              style: DSTextStyles.bodyMd,
            ),
            const SizedBox(height: DSDimens.sizeS),
            DSPillButton(label: 'Add a cat', onPressed: widget.onCreateCat),
          ],
        ),
      );
    }

    final hasMultiple = cats.length > 1;
    final selected = _selectedIndex.clamp(0, cats.length - 1);
    final selectedCat = cats[selected];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text('For your cats', style: DSTextStyles.displayLg),
            ),
            if (hasMultiple)
              Text(
                '${cats.length} CATS',
                style: DSTextStyles.caption.copyWith(
                  color: DSColors.inkSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
          ],
        ),
        const SizedBox(height: DSDimens.sizeXxs),
        Text(
          hasMultiple
              ? "Pick a cat to see how this product fits its profile."
              : "Personalized score based on your cat's profile.",
          style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkSecondary),
        ),
        const SizedBox(height: DSDimens.sizeS),
        if (hasMultiple) ...[
          _CatSelectorRow(
            cats: cats,
            selectedIndex: selected,
            onSelected: (i) => setState(() => _selectedIndex = i),
          ),
          const SizedBox(height: DSDimens.sizeS),
        ],
        CatVerdictCard(
          // Rebuild the card when the selection changes.
          key: ValueKey(selectedCat.id ?? selectedCat.name),
          cat: selectedCat,
          product: widget.product,
        ),
      ],
    );
  }
}

class _CatSelectorRow extends StatelessWidget {
  final List<CatEntity> cats;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _CatSelectorRow({
    required this.cats,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < cats.length; i++) ...[
            if (i > 0) const SizedBox(width: DSDimens.sizeXs),
            _CatSelectorChip(
              cat: cats[i],
              selected: i == selectedIndex,
              onTap: () => onSelected(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _CatSelectorChip extends StatelessWidget {
  final CatEntity cat;
  final bool selected;
  final VoidCallback onTap;

  const _CatSelectorChip({
    required this.cat,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: cat.name,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            DSDimens.sizeXxs,
            DSDimens.sizeXxs,
            DSDimens.sizeS,
            DSDimens.sizeXxs,
          ),
          decoration: BoxDecoration(
            color: selected ? DSColors.inkPrimary : DSColors.surfaceCard,
            borderRadius: BorderRadius.circular(DSRadii.pill),
            border: Border.all(
              color: selected ? DSColors.inkPrimary : DSColors.surfaceCardDim,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CatAvatar(
                photoUrl: cat.profileImageUrl,
                size: 24,
                background: DSColors.tintLavender,
              ),
              const SizedBox(width: DSDimens.sizeXxs),
              Text(
                cat.name,
                style: DSTextStyles.label.copyWith(
                  color:
                      selected ? DSColors.inkInverse : DSColors.inkPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
