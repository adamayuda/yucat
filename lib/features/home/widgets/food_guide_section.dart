import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/home/widgets/home_placeholder_content.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_section_header.dart';

/// "Food guide" swimlane — which human foods a cat can eat, by category.
///
/// Full-bleed by design: the header is inset, the lane is not, so tiles scroll
/// under both screen edges. Add it to the Home `ListView` **without** a
/// `Padding` wrapper.
class FoodGuideSection extends StatelessWidget {
  /// Inert by default — there is no food-guide screen to open yet, but the
  /// link still renders so this header matches `HomeRecipesSection`'s.
  final VoidCallback? onSeeAll;

  /// Inert today, same reason.
  final ValueChanged<FoodGuideCategory>? onCategoryTap;

  const FoodGuideSection({super.key, this.onSeeAll, this.onCategoryTap});

  /// Height the lane occupies — read by the Home skeleton's bone too.
  static const double laneHeight = 116;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = foodGuideCategories(l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
          child: DSSectionHeader(
            title: l10n.homeFoodGuideTitle,
            actionLabel: l10n.homeSeeAll,
            onAction: onSeeAll ?? () {},
          ),
        ),
        const SizedBox(height: DSDimens.sizeS),
        SizedBox(
          height: laneHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
            itemCount: categories.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: DSDimens.sizeXxxs),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _FoodGuideTile(
                category: category,
                onTap: onCategoryTap == null
                    ? null
                    : () => onCategoryTap!(category),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FoodGuideTile extends StatelessWidget {
  final FoodGuideCategory category;
  final VoidCallback? onTap;

  const _FoodGuideTile({required this.category, this.onTap});

  static const double _width = 82;
  static const double _tile = 74;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: category.label,
      button: onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: _width,
          child: Column(
            children: [
              Container(
                width: _tile,
                height: _tile,
                decoration: BoxDecoration(
                  color: DSColors.tintLavender,
                  borderRadius: BorderRadius.circular(DSRadii.lg),
                ),
                alignment: Alignment.center,
                child: ExcludeSemantics(
                  child: Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 34),
                  ),
                ),
              ),
              const SizedBox(height: DSDimens.sizeXxs),
              Flexible(
                child: ExcludeSemantics(
                  child: Text(
                    category.label,
                    style: DSTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: DSColors.inkPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
