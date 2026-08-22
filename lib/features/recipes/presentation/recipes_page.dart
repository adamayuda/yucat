import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/recipes/presentation/bloc/recipes_bloc.dart';
import 'package:yucat/features/recipes/presentation/models/recipe_display_model.dart';
import 'package:yucat/features/recipes/presentation/widgets/recipe_category_strip.dart';
import 'package:yucat/features/recipes/presentation/widgets/recipe_row_card.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_app_bar.dart';
import 'package:yucat/presentation/components/ds_bottom_nav.dart';
import 'package:yucat/presentation/components/ds_state_view.dart';
import 'package:yucat/presentation/components/skeletons/product_list_skeleton.dart';
import 'package:yucat/features/search_products/presentation/widgets/search_text_field.dart';

/// Recipes tab: searchable, category-filtered list of home-made cat treats.
@RoutePage()
class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  late RecipesBloc _bloc;
  String? _language;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Tab pattern: the bloc is owned by the root MultiBlocProvider, so this
    // page reads it and must NOT close it.
    _bloc = context.read<RecipesBloc>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // App language (not the device locale) — the locale the app actually
    // resolved to, so an unsupported device language correctly asks for
    // English. Same rule as scanner_page.dart. Read here rather than in
    // initState because Localizations needs a settled context.
    final language = Localizations.localeOf(context).languageCode;
    if (language == _language) return;
    _language = language;
    _bloc.add(RecipesInitialEvent(language: language));
  }

  @override
  void dispose() {
    // The controller is ours; the bloc is not.
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _bloc.add(RecipesQueryChanged(query: value));
  }

  void _onClear() {
    _searchController.clear();
    _bloc.add(const RecipesQueryChanged(query: ''));
  }

  void _openRecipe(RecipeDisplayModel recipe) {
    context.router.push(RecipeDetailRoute(recipe: recipe));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      // Transparent: the MainPage shell paints DSColors.pageBackground.
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<RecipesBloc, RecipesState>(
          bloc: _bloc,
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DSAppBar.tab(title: l10n.recipesTabTitle),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DSDimens.sizeL,
                    0,
                    DSDimens.sizeL,
                    DSDimens.sizeS,
                  ),
                  child: SearchTextField(
                    controller: _searchController,
                    hintText: l10n.recipesSearchHint,
                    onChanged: _onQueryChanged,
                    onClear: _onClear,
                  ),
                ),
                RecipeCategoryStrip(
                  selected: state is RecipesLoadedState
                      ? state.selectedCategory
                      : null,
                  onSelected: (category) => _bloc.add(
                    RecipesCategorySelected(category: category),
                  ),
                ),
                const SizedBox(height: DSDimens.sizeS),
                Expanded(child: _buildBody(context, state, l10n)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    RecipesState state,
    AppLocalizations l10n,
  ) {
    final bottomInset =
        MediaQuery.of(context).padding.bottom + kFloatingNavClearance;

    return switch (state) {
      RecipesLoadingState() => ProductListSkeleton(
          padding: EdgeInsets.fromLTRB(
            DSDimens.sizeL,
            0,
            DSDimens.sizeL,
            bottomInset,
          ),
        ),
      RecipesErrorState() => DSStateView.error(
          body: l10n.recipesErrorBody,
          onCtaPressed: () =>
              _bloc.add(RecipesInitialEvent(language: _language)),
        ),
      RecipesLoadedState(:final visible) => visible.isEmpty
          ? DSStateView.empty(
              mascotAsset: 'assets/images/cat-thinking.svg',
              tint: DSColors.tintMint,
              headline: l10n.recipesEmptyHeadline,
              body: l10n.recipesEmptyBody,
            )
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(
                DSDimens.sizeL,
                0,
                DSDimens.sizeL,
                bottomInset,
              ),
              itemCount: visible.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: DSDimens.sizeXs),
              itemBuilder: (context, index) {
                final recipe = visible[index];
                return RecipeRowCard(
                  recipe: recipe,
                  onTap: () => _openRecipe(recipe),
                );
              },
            ),
    };
  }
}
