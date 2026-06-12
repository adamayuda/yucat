import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/widgets/cat_verdict_card.dart';
import 'package:yucat/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    final cats = widget.cats;
    if (cats.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
        child: DSCard(
          padding: const EdgeInsets.all(DSDimens.sizeL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.productDetailMyCatScore, style: DSTextStyles.titleMd),
              const SizedBox(height: DSDimens.sizeXxs),
              Text(
                l10n.productDetailNoCatPrompt,
                style: DSTextStyles.bodyMd,
              ),
              const SizedBox(height: DSDimens.sizeS),
              DSPillButton(
                label: l10n.productDetailAddACat,
                onPressed: widget.onCreateCat,
              ),
            ],
          ),
        ),
      );
    }

    final hasMultiple = cats.length > 1;
    final selected = _selectedIndex.clamp(0, cats.length - 1);
    final selectedCat = cats[selected];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      l10n.productDetailForYourCats,
                      style: DSTextStyles.displayLg,
                    ),
                  ),
                  if (hasMultiple)
                    Text(
                      l10n.productDetailCatsCount(cats.length),
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
                    ? l10n.productDetailPickACat
                    : l10n.productDetailPersonalizedScore,
                style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkSecondary),
              ),
            ],
          ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
          child: CatVerdictCard(
            // Rebuild the card when the selection changes.
            key: ValueKey(selectedCat.id ?? selectedCat.name),
            cat: selectedCat,
            product: widget.product,
          ),
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
      // Leading/trailing inset aligns the first chip with the page content;
      // because this row is full-bleed, chips scroll under the screen edges.
      padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
      child: Row(
        children: [
          for (var i = 0; i < cats.length; i++) ...[
            if (i > 0) const SizedBox(width: DSDimens.sizeXxs),
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
            color:
                selected ? DSColors.accentSuccessSoft : DSColors.surfaceCard,
            borderRadius: BorderRadius.circular(DSRadii.pill),
            border: Border.all(
              color: selected ? DSColors.accentSuccess : DSColors.surfaceCardDim,
              width: selected ? 1.5 : 1,
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
                  color: DSColors.inkPrimary,
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
