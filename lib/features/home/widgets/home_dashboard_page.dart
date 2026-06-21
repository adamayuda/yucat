import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/home/widgets/my_cats_section.dart';
import 'package:yucat/features/home/widgets/home_header.dart';
import 'package:yucat/features/home/widgets/saved_products_preview_section.dart';
import 'package:yucat/features/home/widgets/scan_hero_card.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/presentation/components/ds_bottom_nav.dart';

class HomeDashboardPage extends StatelessWidget {
  final List<CatEntity> cats;
  final List<ProductDisplayModel> savedProducts;
  final VoidCallback onScanTap;
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
    required this.onCatTap,
    required this.onProductTap,
    required this.onSeeAllSaved,
    required this.onSeeAllCats,
    required this.onCreateCat,
    required this.onActiveCatChanged,
    required this.onCompleteProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: DSGradients.homeBackground),
        child: SafeArea(
          bottom: false,
          // No horizontal padding here — children add their own so the cat
          // selector inside the My cats section can scroll edge-to-edge.
          child: ListView(
            padding: EdgeInsets.only(
              top: DSDimens.sizeS,
              bottom: MediaQuery.of(context).padding.bottom +
                  kFloatingNavClearance,
            ),
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
                child: HomeHeader(hasCats: cats.isNotEmpty),
              ),
              const SizedBox(height: DSDimens.sizeL),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
                child: ScanHeroCard(onTap: onScanTap),
              ),
              const SizedBox(height: DSDimens.sizeL),
              MyCatsSection(
                cats: cats,
                onCatTap: onCatTap,
                onCreateCat: onCreateCat,
                onActiveCatChanged: onActiveCatChanged,
                onCompleteProfile: onCompleteProfile,
                onSeeAll: onSeeAllCats,
              ),
              const SizedBox(height: DSDimens.sizeL),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
                child: SavedProductsPreviewSection(
                  savedProducts: savedProducts,
                  onProductTap: onProductTap,
                  onSeeAll: onSeeAllSaved,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
