import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/food_guide/presentation/models/food_guide_display_model.dart';
import 'package:yucat/features/home/widgets/food_guide_section.dart';
import 'package:yucat/features/articles/presentation/models/article_display_model.dart';
import 'package:yucat/features/home/widgets/home_articles_section.dart';
import 'package:yucat/features/home/widgets/home_mission_card.dart';
import 'package:yucat/features/home/widgets/home_news_card.dart';
import 'package:yucat/features/home/widgets/home_recipes_section.dart';
import 'package:yucat/features/recipes/presentation/models/recipe_display_model.dart';
import 'package:yucat/features/search_products/presentation/widgets/search_text_field.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_bottom_nav.dart';

/// The Home tab's discovery feed.
///
/// ⚠️ `HomeGreetingCard` (the "Welcome back" card and its cat picker) is
/// **temporarily unmounted** — it and `HomeCatSelector` are still in
/// `lib/features/home/widgets/` and are meant to be reused on another screen.
/// Nothing on this page reads the active cat any more, which is why the page
/// is stateless and takes no cat data.
class HomeDashboardPage extends StatelessWidget {
  final VoidCallback onSearchTap;
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      // Transparent: MainPage paints DSColors.pageBackground behind every tab.
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        // No horizontal padding here — children add their own so the food
        // guide and recipe lanes can scroll edge-to-edge.
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
                onTap: onSearchTap,
              ),
            ),
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
    );
  }
}
