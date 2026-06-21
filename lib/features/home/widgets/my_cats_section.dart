import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/presentation/utils/cat_diet_recommendations.dart';
import 'package:yucat/features/cat/presentation/widgets/dietary_recommendations_card.dart';
import 'package:yucat/features/cat/presentation/widgets/recommended_products_section.dart';
import 'package:yucat/features/home/widgets/active_cat_snapshot_card.dart';
import 'package:yucat/features/home/widgets/cat_profile_completion_card.dart';
import 'package:yucat/features/home/widgets/home_cat_selector.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

/// "My cats" section of the Home dashboard. Groups the cat-selector chips with
/// the overview card they drive under a single titled section (mirrors the
/// Saved products section header). Owns the active-cat selection state.
class MyCatsSection extends StatefulWidget {
  final List<CatEntity> cats;
  final ValueChanged<CatEntity> onCatTap;
  final VoidCallback onCreateCat;
  final ValueChanged<CatEntity> onActiveCatChanged;
  final ValueChanged<CatEntity> onCompleteProfile;
  final VoidCallback onSeeAll;

  const MyCatsSection({
    super.key,
    required this.cats,
    required this.onCatTap,
    required this.onCreateCat,
    required this.onActiveCatChanged,
    required this.onCompleteProfile,
    required this.onSeeAll,
  });

  @override
  State<MyCatsSection> createState() => _MyCatsSectionState();
}

class _MyCatsSectionState extends State<MyCatsSection> {
  int _activeCatIndex = 0;

  @override
  void didUpdateWidget(covariant MyCatsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cats can be re-fetched (e.g. after a scan or creating one); keep the
    // selection in range rather than crashing on a stale index.
    if (_activeCatIndex >= widget.cats.length) {
      _activeCatIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cats = widget.cats;
    final hasCats = cats.isNotEmpty;
    final selected = hasCats ? _activeCatIndex.clamp(0, cats.length - 1) : 0;
    final activeCat = hasCats ? cats[selected] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header — padded to align with page content.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
          child: Row(
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.homeMyCatsTitle,
                    style: DSTextStyles.displayLg,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DSDimens.sizeS),
        if (activeCat == null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
            child: _AddCatCard(onCreateCat: widget.onCreateCat),
          )
        else ...[
          // Chips are full-bleed (no horizontal padding) so they scroll
          // edge-to-edge; only shown when there's more than one cat to pick.
          if (cats.length > 1) ...[
            HomeCatSelector(
              cats: cats,
              selectedIndex: selected,
              onSelected: (i) {
                setState(() => _activeCatIndex = i);
                widget.onActiveCatChanged(cats[i]);
              },
            ),
            const SizedBox(height: DSDimens.sizeS),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
            child: ActiveCatSnapshotCard(
              cat: activeCat,
              onTap: () => widget.onCatTap(activeCat),
            ),
          ),
          if (!catProfileCompletion(activeCat).isComplete)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DSDimens.sizeL,
                DSDimens.sizeS,
                DSDimens.sizeL,
                0,
              ),
              child: CatProfileCompletionCard(
                cat: activeCat,
                onComplete: () => widget.onCompleteProfile(activeCat),
              ),
            ),
          _ActiveCatTips(cat: activeCat, onTap: () => widget.onCatTap(activeCat)),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DSDimens.sizeL,
              DSDimens.sizeL,
              DSDimens.sizeL,
              0,
            ),
            child: RecommendedProductsSection(cat: activeCat),
          ),
        ],
      ],
    );
  }
}

/// Top dietary tips for the active cat, shown under its snapshot. Tapping opens
/// the cat's detail page (where the full list lives). Stays in sync with the
/// selector since it reads the same `activeCat`.
class _ActiveCatTips extends StatelessWidget {
  final CatEntity cat;
  final VoidCallback onTap;

  const _ActiveCatTips({required this.cat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tips = recommendDiet(cat, l10n).take(3).toList();
    if (tips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSDimens.sizeL,
        DSDimens.sizeS,
        DSDimens.sizeL,
        0,
      ),
      child: DietaryRecommendationsCard(
        title: l10n.homeCatTipsTitle(cat.name),
        recommendations: tips,
        showDisclaimer: false,
        onTap: onTap,
      ),
    );
  }
}

class _AddCatCard extends StatelessWidget {
  final VoidCallback onCreateCat;

  const _AddCatCard({required this.onCreateCat});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.homeAddCatTitle, style: DSTextStyles.titleMd),
          const SizedBox(height: DSDimens.sizeXxs),
          Text(
            l10n.homeAddCatBody,
            style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkSecondary),
          ),
          const SizedBox(height: DSDimens.sizeS),
          DSPillButton(
            label: l10n.homeAddCatButton,
            onPressed: onCreateCat,
            showChevron: false,
          ),
        ],
      ),
    );
  }
}
