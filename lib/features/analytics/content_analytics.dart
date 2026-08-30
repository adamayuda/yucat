import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/articles/presentation/models/article_display_model.dart';
import 'package:yucat/features/food_guide/presentation/models/food_guide_display_model.dart';
import 'package:yucat/features/recipes/presentation/models/recipe_display_model.dart';
import 'package:yucat/service_locator.dart';

/// Content-discovery tracking for recipes, articles and the food guide.
///
/// Each item can be opened from more than one surface — a Home lane, the news
/// card, or the item's own list screen — and the property maps must match
/// across all of them or the Mixpanel breakdowns split in two. Hence one helper
/// per content type rather than an inline map at each of the seven call sites.
///
/// ⚠️ Deliberately **not** called from inside the blocs. `ArticlesBloc` is
/// constructed three times concurrently (the news card, the articles lane and
/// `ArticlesPage`), and `RecipesBloc` / `FoodGuideBloc` twice each, so a bloc
/// hook would fire two or three times for one user action. Call these from the
/// widget layer, as `profile_page.dart` does.
///
/// There is no matching `… Detail Viewed` event: the detail pages are stateless
/// and bloc-free, `AnalyticsRouteObserver` already emits `Screen View` for their
/// routes, and every path into them is one of these taps. Add one if the app
/// ever gains deep links into a detail screen.
void logRecipeSelected(RecipeDisplayModel recipe, {required String source}) {
  sl<LogEventUsecase>().call(
    eventName: AnalyticsEvents.recipeSelected,
    properties: {
      'recipe_id': recipe.id,
      'recipe_name': recipe.name,
      'category': recipe.category.wire,
      'difficulty': recipe.difficulty.wire,
      'prep_minutes': recipe.prepMinutes,
      'source': source,
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}

void logArticleSelected(ArticleDisplayModel article, {required String source}) {
  sl<LogEventUsecase>().call(
    eventName: AnalyticsEvents.articleSelected,
    properties: {
      'article_id': article.id,
      'article_title': article.title,
      'category': article.category.wire,
      'read_minutes': article.readMinutes,
      'source': source,
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}

void logFoodGuideItemSelected(
  FoodGuideDisplayModel item, {
  required String source,
}) {
  sl<LogEventUsecase>().call(
    eventName: AnalyticsEvents.foodGuideItemSelected,
    properties: {
      'item_id': item.id,
      'item_name': item.name,
      'safety': item.safety.wire,
      'source': source,
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}

/// Search on a content list screen. Callers debounce — the list blocs filter
/// in memory with no debounce, so hooking the raw query change would emit one
/// event per keystroke. Mirrors `Product Searched`, which sends the raw query
/// alongside its length.
void logContentSearched({
  required String eventName,
  required String query,
  required int resultsCount,
}) {
  sl<LogEventUsecase>().call(
    eventName: eventName,
    properties: {
      'query': query,
      'query_length': query.length,
      'results_count': resultsCount,
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}

/// Category-chip selection. [category] is the enum's `wire` value, or `'all'`
/// for the "All" chip, which the blocs model as a null category.
void logContentFiltered({
  required String eventName,
  required String? category,
  required int resultsCount,
}) {
  sl<LogEventUsecase>().call(
    eventName: eventName,
    properties: {
      'category': category ?? 'all',
      'results_count': resultsCount,
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}
