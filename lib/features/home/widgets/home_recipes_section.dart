import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/recipes/presentation/bloc/recipes_bloc.dart';
import 'package:yucat/features/recipes/presentation/models/recipe_display_model.dart';
import 'package:yucat/features/recipes/presentation/widgets/recipe_poster_card.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_section_header.dart';
import 'package:yucat/presentation/components/ds_shimmer.dart';
import 'package:yucat/service_locator.dart';

/// "Recipes for your cat" swimlane on Home, backed by the real Firestore
/// catalogue.
///
/// Full-bleed: add it to the Home `ListView` **without** a `Padding` wrapper —
/// the header is inset and the lane scrolls under both screen edges.
class HomeRecipesSection extends StatefulWidget {
  final VoidCallback onSeeAll;
  final ValueChanged<RecipeDisplayModel> onRecipeTap;

  const HomeRecipesSection({
    super.key,
    required this.onSeeAll,
    required this.onRecipeTap,
  });

  @override
  State<HomeRecipesSection> createState() => _HomeRecipesSectionState();
}

class _HomeRecipesSectionState extends State<HomeRecipesSection> {
  /// How many of the catalogue's recipes the lane shows, in authored order.
  static const int _laneCount = 6;

  late RecipesBloc _bloc;
  String? _language;

  @override
  void initState() {
    super.initState();
    // A **fresh** bloc, not the root-owned one the Recipes tab reads. Sharing
    // it would break the tab two ways: `_onInitial` emits RecipesLoadingState
    // unconditionally, so this section's fetch would wipe the tab's query and
    // category chip; and `RecipesLoadedState.visible` applies those same
    // filters, which this lane must not inherit. The repository memoizes per
    // language, so the second bloc costs no extra Firestore round-trip.
    _bloc = sl<RecipesBloc>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // App language (not the device locale) — the locale the app actually
    // resolved to, so an unsupported device language correctly asks for
    // English. Same rule as `recipes_page.dart`. Read here rather than in
    // initState because Localizations needs a settled context.
    final language = Localizations.localeOf(context).languageCode;
    if (language == _language) return;
    _language = language;
    _bloc.add(RecipesInitialEvent(language: language));
  }

  @override
  void dispose() {
    // ⚠️ Unlike `RecipesPage` — which reads the root-owned bloc and must NOT
    // close it — this instance is ours, so closing it here is required.
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<RecipesBloc, RecipesState>(
      bloc: _bloc,
      builder: (context, state) {
        // Home is a discovery surface: a lane that failed or has nothing to
        // show removes itself rather than shouting. The Recipes tab still owns
        // the retryable error state.
        final recipes = switch (state) {
          RecipesLoadedState(:final all) => all.take(_laneCount).toList(),
          _ => const <RecipeDisplayModel>[],
        };
        if (state is RecipesErrorState ||
            (state is RecipesLoadedState && recipes.isEmpty)) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
              child: DSSectionHeader(
                title: l10n.homeRecipesSectionTitle,
                actionLabel: l10n.homeSeeAll,
                onAction: widget.onSeeAll,
              ),
            ),
            const SizedBox(height: DSDimens.sizeS),
            SizedBox(
              height: RecipePosterCard.laneHeight,
              child: state is RecipesLoadedState
                  ? ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: DSDimens.sizeL,
                      ),
                      itemCount: recipes.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: DSDimens.sizeS),
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return RecipePosterCard(
                          recipe: recipe,
                          onTap: () => widget.onRecipeTap(recipe),
                        );
                      },
                    )
                  : const _RecipeLaneShimmer(),
            ),
          ],
        );
      },
    );
  }
}

/// Poster bones while the catalogue loads. The lane's `SizedBox` clips the
/// overhang, so the row can be wider than the screen the way the real lane is.
class _RecipeLaneShimmer extends StatelessWidget {
  const _RecipeLaneShimmer();

  @override
  Widget build(BuildContext context) {
    return DSShimmer(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
        itemCount: 2,
        separatorBuilder: (_, __) => const SizedBox(width: DSDimens.sizeS),
        itemBuilder: (_, __) => const ShimmerBone(
          width: RecipePosterCard.width,
          height: RecipePosterCard.laneHeight,
          radius: DSRadii.xl,
        ),
      ),
    );
  }
}
