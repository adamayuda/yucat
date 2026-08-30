import 'package:flutter/widgets.dart';
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
/// There is no matching `… Detail Viewed` event: the detail pages are bloc-free,
/// `AnalyticsRouteObserver` already emits `Screen View` for their routes, and
/// every path into them is one of these taps. Add one if the app ever gains
/// deep links into a detail screen. Articles are the exception — they get
/// [logArticleRead] on pop, because a tap says nothing about whether the
/// article was actually read.
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

/// Read depth on the article detail screen, emitted once when the screen is
/// popped.
///
/// [AnalyticsEvents.articleSelected] only says the card was tapped. The pair
/// that matters is [seconds] against the article's own claimed `read_minutes`
/// (also sent, so the ratio is computable in Mixpanel without a join) and
/// [scrollPct], which separates "opened and bounced" from "actually read".
void logArticleRead(
  ArticleDisplayModel article, {
  required int seconds,
  required int scrollPct,
}) {
  sl<LogEventUsecase>().call(
    eventName: AnalyticsEvents.articleRead,
    properties: {
      'article_id': article.id,
      'article_title': article.title,
      'category': article.category.wire,
      // Claimed read time, from the seeded content.
      'read_minutes': article.readMinutes,
      // Actual dwell time and furthest scroll reached, 0-100.
      'seconds': seconds,
      'scroll_pct': scrollPct,
      // Length control: a 2-paragraph article reaching 100% is not the same
      // achievement as a 12-paragraph one doing so.
      'paragraphs': article.body.length,
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}

/// A Home content lane rendered with at least one item.
///
/// The denominator for lane conversion. Every lane hides itself entirely on an
/// error or empty catalogue, so `Screen View(HomeRoute)` over-counts as a
/// denominator — a lane that never appeared cannot have been ignored. Emitted
/// once per load rather than per rebuild; see the `_loggedItemCount` guards in
/// the section widgets.
void logContentLaneViewed({
  required String section,
  required int itemCount,
}) {
  sl<LogEventUsecase>().call(
    eventName: AnalyticsEvents.contentLaneViewed,
    properties: {
      'section': section,
      'item_count': itemCount,
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

/// Emits [AnalyticsEvents.contentLaneViewed] at most once per lane appearance.
///
/// Mixed into the four Home section States rather than written inline four
/// times, because all four need the same two non-obvious guards:
///
/// * **Once per appearance, not per rebuild.** `HomeDashboardPage` is stateless
///   and is rebuilt by `HomePage`'s `BlocBuilder<HomeBloc, …>` on any HomeBloc
///   emission, so each section's `build` runs many times for a single load. The
///   flag lives in State, so a fresh mount (e.g. returning from the scan
///   theater, which unmounts the dashboard entirely) correctly counts again,
///   and [resetLaneViewed] re-arms it when the language changes and the lane
///   genuinely reloads.
/// * **Never during build.** [reportLaneViewed] is safe to call from a
///   `BlocBuilder` body because it defers to a post-frame callback — logging
///   inline would be a side effect inside the build phase.
mixin ContentLaneAnalytics<T extends StatefulWidget> on State<T> {
  bool _laneViewedLogged = false;

  /// Re-arms the event. Call wherever the lane's underlying load restarts —
  /// in practice the language change in `didChangeDependencies`.
  void resetLaneViewed() => _laneViewedLogged = false;

  /// Records that [section] rendered with [itemCount] items. A count of zero is
  /// ignored: every lane hides itself when empty, and a lane that never
  /// appeared must not land in the denominator.
  void reportLaneViewed({required String section, required int itemCount}) {
    if (_laneViewedLogged || itemCount <= 0) return;
    _laneViewedLogged = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      logContentLaneViewed(section: section, itemCount: itemCount);
    });
  }
}
