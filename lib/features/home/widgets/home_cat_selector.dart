import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/presentation/components/cat_avatar.dart';

/// Horizontal avatar-chip row that selects the active cat for the Home screen.
/// Mirrors the selector in `cat_assessment_card.dart`.
class HomeCatSelector extends StatelessWidget {
  final List<CatEntity> cats;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const HomeCatSelector({
    super.key,
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
                  color: selected ? DSColors.inkInverse : DSColors.inkPrimary,
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
