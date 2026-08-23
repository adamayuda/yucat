import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';
import 'package:yucat/features/food_guide/presentation/models/food_guide_display_model.dart';
import 'package:yucat/features/home/bloc/home_bloc.dart';
import 'package:yucat/features/home/bloc/home_event.dart';
import 'package:yucat/features/home/bloc/home_state.dart';
import 'package:yucat/features/home/widgets/home_dashboard_page.dart';
import 'package:yucat/features/home/widgets/home_loading_page.dart';
import 'package:yucat/features/home/widgets/home_skeleton.dart';
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

  /// Recipes is tab index 1 of `MainRoute`. ⚠️ Tab identity is duplicated in
  /// `main_page.dart`, `router.dart` and `bottom_nav_bar.dart` (docs/design.md
  /// §8c) — this is a fourth reader of that order. The screen-view log mirrors
  /// what the nav emits on a tab switch.
  void _openRecipesTab() {
    AutoTabsRouter.of(context).setActiveIndex(1);
    sl<LogScreenViewUsecase>()(screenName: RecipesRoute.name);
  }

  void _openRecipe(RecipeDisplayModel recipe) {
    context.router.push(RecipeDetailRoute(recipe: recipe));
  }

  void _openFoodGuideItem(FoodGuideDisplayModel item) {
    context.router.push(FoodGuideDetailRoute(item: item));
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
      case HomeScanningState(:final imageBase64):
        return Scaffold(
          backgroundColor: DSColors.pageBackground,
          body: HomeLoadingWidget(imageBase64: imageBase64),
        );
      // `cats` is still loaded by HomeBloc — it drives the People-profile sync
      // and the OneSignal `has_cat` tag — but nothing on the page renders it
      // while the greeting card is unmounted.
      case HomeLoadedState():
        return HomeDashboardPage(
          onSearchTap: _openSearch,
          onSeeAllRecipes: _openRecipesTab,
          onRecipeTap: _openRecipe,
          onFoodGuideTap: _openFoodGuideItem,
        );
      case HomeErrorState():
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          backgroundColor: DSColors.pageBackground,
          body: SafeArea(
            child: DSStateView.error(
              body: _localizeError(state.errorType, l10n),
              onCtaPressed: () => _bloc.add(HomeInitialEvent()),
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _localizeError(HomeErrorType type, AppLocalizations l10n) =>
      switch (type) {
        HomeErrorType.notFound => l10n.homeErrorProductNotFound,
        HomeErrorType.timeout => l10n.homeErrorTimeout,
        HomeErrorType.noInternet => l10n.homeErrorNoInternet,
        HomeErrorType.generic => l10n.homeErrorGeneric,
      };
}
