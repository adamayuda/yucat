import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/home/widgets/active_cat_snapshot_card.dart';
import 'package:yucat/features/home/widgets/home_cat_selector.dart';
import 'package:yucat/features/home/widgets/home_header.dart';
import 'package:yucat/features/home/widgets/saved_products_preview_section.dart';
import 'package:yucat/features/home/widgets/scan_hero_card.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/presentation/components/ds_bottom_nav.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

class HomeDashboardPage extends StatefulWidget {
  final List<CatEntity> cats;
  final List<ProductDisplayModel> savedProducts;
  final VoidCallback onScanTap;
  final ValueChanged<CatEntity> onCatTap;
  final ValueChanged<ProductDisplayModel> onProductTap;
  final VoidCallback onSeeAllSaved;
  final VoidCallback onCreateCat;
  final ValueChanged<CatEntity> onActiveCatChanged;

  const HomeDashboardPage({
    super.key,
    required this.cats,
    required this.savedProducts,
    required this.onScanTap,
    required this.onCatTap,
    required this.onProductTap,
    required this.onSeeAllSaved,
    required this.onCreateCat,
    required this.onActiveCatChanged,
  });

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  int _activeCatIndex = 0;

  @override
  void didUpdateWidget(covariant HomeDashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cats can be re-fetched (e.g. after a scan or creating one); keep the
    // selection in range rather than crashing on a stale index.
    if (_activeCatIndex >= widget.cats.length) {
      _activeCatIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cats = widget.cats;
    final hasCats = cats.isNotEmpty;
    final selected = hasCats ? _activeCatIndex.clamp(0, cats.length - 1) : 0;
    final activeCat = hasCats ? cats[selected] : null;

    return Scaffold(
      backgroundColor: DSColors.tintLavender,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            DSDimens.sizeL,
            DSDimens.sizeS,
            DSDimens.sizeL,
            MediaQuery.of(context).padding.bottom + kFloatingNavClearance,
          ),
          children: [
            HomeHeader(activeCat: activeCat),
            const SizedBox(height: DSDimens.sizeL),
            if (cats.length > 1) ...[
              HomeCatSelector(
                cats: cats,
                selectedIndex: selected,
                onSelected: (i) {
                  setState(() => _activeCatIndex = i);
                  widget.onActiveCatChanged(cats[i]);
                },
              ),
              const SizedBox(height: DSDimens.sizeL),
            ],
            ScanHeroCard(onTap: widget.onScanTap),
            const SizedBox(height: DSDimens.sizeM),
            if (activeCat != null)
              ActiveCatSnapshotCard(
                cat: activeCat,
                onTap: () => widget.onCatTap(activeCat),
              )
            else
              _AddCatCard(onCreateCat: widget.onCreateCat),
            const SizedBox(height: DSDimens.sizeL),
            SavedProductsPreviewSection(
              savedProducts: widget.savedProducts,
              onProductTap: widget.onProductTap,
              onSeeAll: widget.onSeeAllSaved,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCatCard extends StatelessWidget {
  final VoidCallback onCreateCat;

  const _AddCatCard({required this.onCreateCat});

  @override
  Widget build(BuildContext context) {
    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add your cat', style: DSTextStyles.titleMd),
          const SizedBox(height: DSDimens.sizeXxs),
          Text(
            'Create a profile to get personalized food scores.',
            style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkSecondary),
          ),
          const SizedBox(height: DSDimens.sizeS),
          DSPillButton(
            label: 'Add a cat',
            onPressed: onCreateCat,
            showChevron: false,
          ),
        ],
      ),
    );
  }
}
