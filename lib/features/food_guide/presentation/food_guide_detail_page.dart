import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/food_guide/presentation/models/food_guide_display_model.dart';
import 'package:yucat/features/food_guide/presentation/widgets/food_guide_labels.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_circle_icon_button.dart';
import 'package:yucat/presentation/components/ds_tip_card.dart';

/// One food category: hero, name, safety pill, description, the fact rows that
/// apply, and an optional tip.
///
/// Stateless with no bloc — like `RecipeDetailPage`, everything rendered here
/// arrives on the model the route carries, so there is no async work.
@RoutePage()
class FoodGuideDetailPage extends StatelessWidget {
  final FoodGuideDisplayModel item;

  const FoodGuideDetailPage({super.key, required this.item});

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
              _Hero(
                imageUrl: item.imageUrl,
                emoji: item.emoji,
                height: _heroHeight,
              ),
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
                    Text(item.name, style: DSTextStyles.displayLg),
                    const SizedBox(height: DSDimens.sizeXs),
                    FoodSafetyPill(safety: item.safety),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: DSDimens.sizeS),
                      Text(
                        item.description,
                        style: DSTextStyles.bodyLg.copyWith(
                          color: DSColors.inkSecondary,
                        ),
                      ),
                    ],
                    if (item.hasFacts) ...[
                      const SizedBox(height: DSDimens.sizeL),
                      _FactsCard(item: item, l10n: l10n),
                    ],
                    if (item.tip != null) ...[
                      const SizedBox(height: DSDimens.sizeL),
                      DSTipCard(
                        title: l10n.foodGuideTip,
                        body: item.tip!,
                      ),
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
  final String emoji;
  final double height;

  const _Hero({
    required this.imageUrl,
    required this.emoji,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Null-check first so a category with no photo never starts a network
    // request; the tint sits behind the image so there's no white flash.
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Container(
      height: height,
      width: double.infinity,
      color: DSColors.tintLavender,
      alignment: Alignment.center,
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              height: height,
              width: double.infinity,
              errorBuilder: (_, __, ___) =>
                  FoodGuideEmoji(emoji: emoji, size: 96),
            )
          : FoodGuideEmoji(emoji: emoji, size: 96),
    );
  }
}

/// The why / how / avoid rows. Each renders only when its copy exists, so a
/// dangerous food shows the avoid row alone.
class _FactsCard extends StatelessWidget {
  final FoodGuideDisplayModel item;
  final AppLocalizations l10n;

  const _FactsCard({required this.item, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final rows = <_Fact>[
      if (item.whyGood != null)
        _Fact(
          icon: Icons.check_rounded,
          background: DSColors.accentSuccessSoft,
          foreground: DSColors.accentSuccess,
          title: l10n.foodGuideWhyGood,
          body: item.whyGood!,
        ),
      if (item.howToServe != null)
        _Fact(
          icon: Icons.restaurant_rounded,
          background: DSColors.tintBlueSoft,
          foreground: DSColors.accentInfo,
          title: l10n.foodGuideHowToServe,
          body: item.howToServe!,
        ),
      if (item.avoid != null)
        _Fact(
          icon: Icons.priority_high_rounded,
          background: DSColors.tintCoral,
          foreground: DSColors.accentDanger,
          title: l10n.foodGuideAvoid,
          body: item.avoid!,
        ),
    ];

    return DSCard(
      padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeS),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
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
              child: rows[i],
            ),
          ],
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color foreground;
  final String title;
  final String body;

  const _Fact({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Icon(icon, color: foreground, size: 18),
        ),
        const SizedBox(width: DSDimens.sizeS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: DSTextStyles.titleMd),
              const SizedBox(height: DSDimens.sizeXxxs),
              Text(
                body,
                style: DSTextStyles.bodyMd.copyWith(
                  color: DSColors.inkSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
