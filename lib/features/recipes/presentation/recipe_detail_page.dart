import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/recipes/domain/entities/recipe_entity.dart';
import 'package:yucat/features/recipes/presentation/models/recipe_display_model.dart';
import 'package:yucat/features/recipes/presentation/widgets/recipe_labels.dart';
import 'package:yucat/features/recipes/presentation/widgets/recipe_meta.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_circle_icon_button.dart';

/// A single recipe: hero, meta, ingredients, numbered steps and an optional tip.
///
/// Stateless with no bloc — unlike `ProductDetailPage`, everything rendered here
/// arrives on the model handed over by the route, so there is no async work to
/// orchestrate.
@RoutePage()
class RecipeDetailPage extends StatelessWidget {
  final RecipeDisplayModel recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  static const double _heroHeight = 260;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: DSColors.pageBackground,
      // No top SafeArea: the hero deliberately bleeds under the status bar, and
      // the back button is inset by the padding instead.
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + DSDimens.sizeL,
            ),
            children: [
              _Hero(imageUrl: recipe.imageUrl, height: _heroHeight),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DSDimens.sizeL,
                  DSDimens.sizeL,
                  DSDimens.sizeL,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.name, style: DSTextStyles.displayLg),
                    const SizedBox(height: DSDimens.sizeXs),
                    RecipeMetaRow(
                      prep: recipe.prepLabel(l10n),
                      difficulty: recipe.difficulty.label(l10n),
                    ),
                    const SizedBox(height: DSDimens.sizeXs),
                    RecipeCompatibilityPill(
                      compatibility: recipe.compatibility,
                    ),
                    if (recipe.ingredients.isNotEmpty) ...[
                      const SizedBox(height: DSDimens.sizeL),
                      _SectionHeader(title: l10n.recipeDetailIngredients),
                      const SizedBox(height: DSDimens.sizeXs),
                      _IngredientsCard(ingredients: recipe.ingredients),
                    ],
                    if (recipe.steps.isNotEmpty) ...[
                      const SizedBox(height: DSDimens.sizeL),
                      _SectionHeader(title: l10n.recipeDetailPreparation),
                      const SizedBox(height: DSDimens.sizeXs),
                      for (var i = 0; i < recipe.steps.length; i++) ...[
                        if (i > 0) const SizedBox(height: DSDimens.sizeXs),
                        _StepCard(number: i + 1, text: recipe.steps[i]),
                      ],
                    ],
                    if (recipe.tip != null) ...[
                      const SizedBox(height: DSDimens.sizeL),
                      _TipCard(tip: recipe.tip!),
                    ],
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: topInset + DSDimens.sizeXxs,
            left: DSDimens.sizeL,
            child: DSCircleIconButton(
              icon: Icons.chevron_left,
              size: 40,
              onPressed: () => context.router.maybePop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final String? imageUrl;
  final double height;

  const _Hero({required this.imageUrl, required this.height});

  @override
  Widget build(BuildContext context) {
    // Null-check first so a recipe with no photo never starts a network request.
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Container(
      height: height,
      width: double.infinity,
      color: DSColors.tintSand,
      alignment: Alignment.center,
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              height: height,
              width: double.infinity,
              errorBuilder: (_, __, ___) => const _HeroPlaceholder(),
            )
          : const _HeroPlaceholder(),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.ramen_dining_rounded,
        color: DSColors.inkTertiary,
        size: 56,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: DSTextStyles.headlineMd);
  }
}

class _IngredientsCard extends StatelessWidget {
  final List<RecipeIngredient> ingredients;

  const _IngredientsCard({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return DSCard(
      padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeS),
      child: Column(
        children: [
          for (var i = 0; i < ingredients.length; i++) ...[
            // Rules go between rows only — a trailing one would read as a
            // cut-off list.
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: DSColors.surfaceCardDim,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: DSDimens.sizeS),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      ingredients[i].name,
                      style: DSTextStyles.bodyLg,
                    ),
                  ),
                  const SizedBox(width: DSDimens.sizeS),
                  Text(
                    ingredients[i].quantity,
                    style: DSTextStyles.bodyLg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int number;
  final String text;

  const _StepCard({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: DSColors.tintBlueSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: DSTextStyles.label.copyWith(
                color: DSColors.accentInfo,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: DSDimens.sizeS),
          Expanded(child: Text(text, style: DSTextStyles.bodyLg)),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String tip;

  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DSCard(
      background: DSColors.tintCream,
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: DSColors.surfaceCard.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: DSColors.coralAccent,
              size: 18,
            ),
          ),
          const SizedBox(width: DSDimens.sizeS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.recipeDetailTip, style: DSTextStyles.titleMd),
                const SizedBox(height: DSDimens.sizeXxxs),
                Text(
                  tip,
                  style: DSTextStyles.bodyMd.copyWith(
                    color: DSColors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
