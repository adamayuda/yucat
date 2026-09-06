import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/food_guide/presentation/models/food_guide_display_model.dart';
import 'package:yucat/features/home/widgets/food_guide_section.dart';
import 'package:yucat/features/articles/presentation/models/article_display_model.dart';
import 'package:yucat/features/home/widgets/home_articles_section.dart';
import 'package:yucat/features/home/widgets/home_mission_card.dart';
import 'package:yucat/features/home/widgets/home_news_card.dart';
import 'package:yucat/features/home/widgets/home_recipes_section.dart';
import 'package:yucat/features/home/widgets/home_scan_header.dart';
import 'package:yucat/features/recipes/presentation/models/recipe_display_model.dart';
import 'package:yucat/presentation/components/ds_bottom_nav.dart';

/// The Home tab's discovery feed: [HomeScanHeader] (search + the scan CTA, as
/// one blue slab) then the news card and the content lanes.
///
/// ⚠️ The header bleeds under the status bar, so this page's `SafeArea` passes
/// `top: false` and the list starts at zero top padding — [HomeScanHeader] adds
/// `MediaQuery.padding.top` itself. Reinstating the top inset here would leave
/// a `pageBackground` band above the blue, which is exactly the two-sections
/// look the header replaced.
///
/// ⚠️ `HomeGreetingCard` (the "Welcome back" card and its cat picker) is
/// **temporarily unmounted** — it and `HomeCatSelector` are still in
/// `lib/features/home/widgets/` and are meant to be reused on another screen.
/// Nothing on this page reads the active cat any more, which is why the page
/// is stateless and takes no cat data.
class HomeDashboardPage extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onScanTap;
  final VoidCallback onSeeAllRecipes;
  final ValueChanged<RecipeDisplayModel> onRecipeTap;
  final ValueChanged<FoodGuideDisplayModel> onFoodGuideTap;
  final VoidCallback onSeeAllFoodGuide;
  final VoidCallback onSeeAllArticles;
  final ValueChanged<ArticleDisplayModel> onArticleTap;

  /// The news card opens an article too, but from a different surface — kept
  /// separate from [onArticleTap] purely so analytics can tell the two apart.
  final ValueChanged<ArticleDisplayModel> onNewsArticleTap;

  const HomeDashboardPage({
    super.key,
    required this.onSearchTap,
    required this.onScanTap,
    required this.onSeeAllRecipes,
    required this.onRecipeTap,
    required this.onFoodGuideTap,
    required this.onSeeAllFoodGuide,
    required this.onSeeAllArticles,
    required this.onArticleTap,
    required this.onNewsArticleTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // The page default. HomeScanHeader annotates itself light; once it
      // scrolls off the top of the screen this takes over again, so the status
      // bar icons follow whatever is actually under them.
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        // Transparent: MainPage paints DSColors.pageBackground behind every tab.
        backgroundColor: Colors.transparent,
        body: SafeArea(
          // `top: false` — the header paints under the status bar and adds the
          // inset itself. See the class doc.
          top: false,
          bottom: false,
          // No horizontal padding here — children add their own so the food
          // guide and recipe lanes can scroll edge-to-edge.
          child: ListView(
            padding: EdgeInsets.only(
              bottom:
                  MediaQuery.of(context).padding.bottom + kFloatingNavClearance,
            ),
            children: [
              // Unpadded on purpose: the blue runs to both screen edges.
              HomeScanHeader(onSearchTap: onSearchTap, onScanTap: onScanTap),
              const SizedBox(height: DSDimens.sizeL),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
                child: HomeNewsCard(onArticleTap: onNewsArticleTap),
              ),
              const SizedBox(height: DSDimens.sizeL),
              // Unpadded on purpose — the lane scrolls under the screen edges.
              FoodGuideSection(
                onSeeAll: onSeeAllFoodGuide,
                onCategoryTap: onFoodGuideTap,
              ),
              const SizedBox(height: DSDimens.sizeL),
              HomeRecipesSection(
                onSeeAll: onSeeAllRecipes,
                onRecipeTap: onRecipeTap,
              ),
              const SizedBox(height: DSDimens.sizeL),
              HomeArticlesSection(
                onSeeAll: onSeeAllArticles,
                onArticleTap: onArticleTap,
              ),
              const SizedBox(height: DSDimens.sizeL),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
                child: HomeMissionCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
