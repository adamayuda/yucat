import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/home/widgets/my_cats_section.dart';
import 'package:yucat/features/home/widgets/home_greeting_card.dart';
import 'package:yucat/features/home/widgets/saved_products_preview_section.dart';
import 'package:yucat/features/home/widgets/scan_hero_card.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/search_products/presentation/widgets/search_text_field.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_bottom_nav.dart';

class HomeDashboardPage extends StatefulWidget {
  final List<CatEntity> cats;
  final List<ProductDisplayModel> savedProducts;
  final VoidCallback onScanTap;
  final VoidCallback onSearchTap;
  final ValueChanged<CatEntity> onCatTap;
  final ValueChanged<ProductDisplayModel> onProductTap;
  final VoidCallback onSeeAllSaved;
  final VoidCallback onSeeAllCats;
  final VoidCallback onCreateCat;
  final ValueChanged<CatEntity> onActiveCatChanged;
  final ValueChanged<CatEntity> onCompleteProfile;

  const HomeDashboardPage({
    super.key,
    required this.cats,
    required this.savedProducts,
    required this.onScanTap,
    required this.onSearchTap,
    required this.onCatTap,
    required this.onProductTap,
    required this.onSeeAllSaved,
    required this.onSeeAllCats,
    required this.onCreateCat,
    required this.onActiveCatChanged,
    required this.onCompleteProfile,
  });

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  /// Which cat the greeting card has selected. Owned here rather than in the
  /// picker so the My cats section below reads the same choice.
  int _activeCatIndex = 0;

  @override
  void didUpdateWidget(covariant HomeDashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cats get re-fetched (after a scan, an edit, or a deletion); keep the
    // selection in range rather than indexing past the end of a shorter list.
    if (_activeCatIndex >= widget.cats.length) {
      _activeCatIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cats = widget.cats;
    final selected = cats.isEmpty ? 0 : _activeCatIndex.clamp(0, cats.length - 1);
    final activeCat = cats.isEmpty ? null : cats[selected];

    return Scaffold(
      // Transparent: MainPage paints DSColors.pageBackground behind every tab.
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        // No horizontal padding here — children add their own so the cat
        // selector inside the My cats section can scroll edge-to-edge.
        child: ListView(
          padding: EdgeInsets.only(
            top: DSDimens.sizeS,
            bottom:
                MediaQuery.of(context).padding.bottom + kFloatingNavClearance,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
              child: SearchTextField(
                readOnly: true,
                hintText: l10n.searchHint,
                onTap: widget.onSearchTap,
              ),
            ),
            const SizedBox(height: DSDimens.sizeL),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
              child: HomeGreetingCard(
                cats: cats,
                selectedIndex: selected,
                onCatSelected: _onCatSelected,
                onAddCat: widget.onCreateCat,
              ),
            ),
            const SizedBox(height: DSDimens.sizeL),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
              child: ScanHeroCard(onTap: widget.onScanTap),
            ),
            const SizedBox(height: DSDimens.sizeL),
            MyCatsSection(
              activeCat: activeCat,
              onCatTap: widget.onCatTap,
              onCompleteProfile: widget.onCompleteProfile,
            ),
            const SizedBox(height: DSDimens.sizeL),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
              child: SavedProductsPreviewSection(
                savedProducts: widget.savedProducts,
                onProductTap: widget.onProductTap,
                onSeeAll: widget.onSeeAllSaved,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCatSelected(int index) {
    setState(() => _activeCatIndex = index);
    widget.onActiveCatChanged(widget.cats[index]);
  }
}
