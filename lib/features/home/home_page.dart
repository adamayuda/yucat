import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/content_analytics.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';
import 'package:yucat/features/articles/presentation/models/article_display_model.dart';
import 'package:yucat/features/food_guide/presentation/models/food_guide_display_model.dart';
import 'package:yucat/features/home/bloc/home_bloc.dart';
import 'package:yucat/features/home/bloc/home_event.dart';
import 'package:yucat/features/home/bloc/home_state.dart';
import 'package:yucat/features/home/widgets/home_dashboard_page.dart';
import 'package:yucat/features/home/widgets/home_loading_page.dart';
import 'package:yucat/features/home/widgets/home_scan_error_view.dart';
import 'package:yucat/features/home/widgets/home_skeleton.dart';
import 'package:yucat/features/product/domain/entities/label_target.dart';
import 'package:yucat/features/recipes/presentation/models/recipe_display_model.dart';
import 'package:yucat/presentation/components/ds_state_view.dart';
import 'package:yucat/service_locator.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  late HomeBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<HomeBloc>();
    _bloc.add(HomeInitialEvent());
  }

  // NOTE: HomeBloc's lifecycle is owned by the root MultiBlocProvider in
  // main.dart — this page must NOT close it. Closing it here left a dead bloc
  // in the shared provider, so re-mounting the Home tab threw "Cannot add new
  // events after calling close" from initState.

  void _openSearch() {
    context.router.push(const SearchRoute());
  }

  /// Home's scan CTA. Unlike the nav's Scan slot there is no `setActiveIndex`
  /// dance here — Home is already the active tab, which is the tab the scan
  /// theater (`HomeScanningState`) paints on.
  void _openScanner() {
    sl<LogEventUsecase>().call(
      eventName: AnalyticsEvents.scanStarted,
      properties: {
        'source': ScanSource.homeHeader,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    context.router.push(ScannerRoute());
  }

  /// Recipes is tab index 1 of `MainRoute`. ⚠️ Tab identity is duplicated in
  /// `main_page.dart`, `router.dart` and `bottom_nav_bar.dart` (docs/design.md
  /// §8c) — this is a fourth reader of that order. The screen-view log mirrors
  /// what the nav emits on a tab switch.
  void _openRecipesTab() {
    _logSeeAll(ContentSection.recipes);
    AutoTabsRouter.of(context).setActiveIndex(1);
    sl<LogScreenViewUsecase>()(screenName: RecipesRoute.name);
  }

  void _openRecipe(RecipeDisplayModel recipe) {
    logRecipeSelected(recipe, source: ContentSource.homeLane);
    context.router.push(RecipeDetailRoute(recipe: recipe));
  }

  void _openFoodGuideItem(FoodGuideDisplayModel item) {
    logFoodGuideItemSelected(item, source: ContentSource.homeLane);
    context.router.push(FoodGuideDetailRoute(item: item));
  }

  void _openFoodGuide() {
    _logSeeAll(ContentSection.foodGuide);
    context.router.push(const FoodGuideRoute());
  }

  void _openArticles() {
    _logSeeAll(ContentSection.articles);
    context.router.push(const ArticlesRoute());
  }

  void _openArticle(ArticleDisplayModel article) {
    logArticleSelected(article, source: ContentSource.homeLane);
    context.router.push(ArticleDetailRoute(article: article));
  }

  // NOTE: `_openNewsArticle` went with `HomeNewsCard` in YUC-24 — it was
  // `_openArticle` with `ContentSource.homeNewsCard` instead of `homeLane`.
  // `ContentSource.homeNewsCard` is kept but is now unreachable; restore both
  // together if the card is re-mounted.

  void _logSeeAll(String section) {
    sl<LogEventUsecase>().call(
      eventName: AnalyticsEvents.contentSeeAllTapped,
      properties: {
        'section': section,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: _bloc,
      builder: (context, state) => _onStateChangeBuilder(context, state),
    );
  }

  Widget _onStateChangeBuilder(BuildContext context, HomeState state) {
    switch (state) {
      case HomeLoadingState():
        return Scaffold(
          backgroundColor: DSColors.pageBackground,
          body: const HomeSkeleton(),
        );
      case HomeScanningState(:final imageBase64, :final mode):
        return Scaffold(
          backgroundColor: DSColors.pageBackground,
          body: HomeLoadingWidget(
            imageBase64: imageBase64,
            mode: mode,
            onCancel: () => _bloc.add(const ScanAbandonedEvent()),
          ),
        );
      // `cats` is still loaded by HomeBloc — it drives the People-profile sync
      // and the OneSignal `has_cat` tag — but nothing on the page renders it
      // while the greeting card is unmounted.
      case HomeLoadedState():
        return HomeDashboardPage(
          onSearchTap: _openSearch,
          onScanTap: _openScanner,
          onSeeAllRecipes: _openRecipesTab,
          onRecipeTap: _openRecipe,
          onFoodGuideTap: _openFoodGuideItem,
          onSeeAllFoodGuide: _openFoodGuide,
          onSeeAllArticles: _openArticles,
          onArticleTap: _openArticle,
        );
      case HomeErrorState():
        final l10n = AppLocalizations.of(context);
        // A classified scan outcome gets the per-outcome view with its exits;
        // transport errors (timeout, offline, busy) keep the plain retry.
        if (state.outcome != null) {
          return Scaffold(
            backgroundColor: DSColors.pageBackground,
            body: SafeArea(
              child: HomeScanErrorView(
                state: state,
                onScanAgain: () => _onScanErrorExit(state, 'scan_again'),
                onScanLabel: () => _onScanErrorExit(state, 'scan_label'),
                onSearch: () => _onScanErrorExit(state, 'search'),
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: DSColors.pageBackground,
          body: SafeArea(
            child: DSStateView.error(
              body: _localizeError(state.errorType, l10n),
              // Without this the widget's hard-coded English default shipped
              // in all six locales.
              ctaLabel: l10n.commonTryAgain,
              onCtaPressed: () => _bloc.add(HomeInitialEvent()),
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// One of the three exits on the scan error view. Home goes back to its
  /// dashboard first, so the error is not still waiting when the user returns
  /// from the pushed screen.
  void _onScanErrorExit(HomeErrorState state, String exit) {
    sl<LogEventUsecase>().call(
      eventName: AnalyticsEvents.scanErrorExitTapped,
      properties: {
        'outcome': state.outcome,
        'exit': exit,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    _bloc.add(HomeInitialEvent());
    switch (exit) {
      case 'scan_again':
        sl<LogEventUsecase>().call(
          eventName: AnalyticsEvents.scanStarted,
          properties: {
            'source': ScanSource.scanErrorRetry,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        context.router.push(ScannerRoute());
      case 'scan_label':
        sl<LogEventUsecase>().call(
          eventName: AnalyticsEvents.labelScanStarted,
          properties: {
            'source': ScanSource.scanError,
            'outcome': state.outcome,
            'has_product_key': state.productKey != null,
            'has_gtin': state.gtin != null,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
        context.router.push(ScannerRoute(
          mode: ScanMode.label,
          labelTarget: LabelTarget(
            productKey: state.productKey,
            gtin: state.gtin,
            brand: state.identifiedBrand,
            name: state.identifiedName,
          ),
        ));
      case 'search':
        context.router.push(const SearchRoute());
    }
  }

  String _localizeError(HomeErrorType type, AppLocalizations l10n) =>
      switch (type) {
        HomeErrorType.notFound => l10n.homeErrorProductNotFound,
        HomeErrorType.timeout => l10n.homeErrorTimeout,
        HomeErrorType.noInternet => l10n.homeErrorNoInternet,
        HomeErrorType.serviceBusy => l10n.homeErrorServiceBusy,
        // Both label failures always carry an `outcome`, so they render
        // through HomeScanErrorView above; these are the safety net.
        HomeErrorType.labelUnreadable => l10n.homeErrorLabelUnreadableBody,
        HomeErrorType.labelNoData => l10n.homeErrorLabelNoDataBody,
        HomeErrorType.generic => l10n.homeErrorGeneric,
      };
}
