import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/food_guide/presentation/bloc/food_guide_bloc.dart';
import 'package:yucat/features/food_guide/presentation/models/food_guide_display_model.dart';
import 'package:yucat/features/food_guide/presentation/widgets/food_guide_labels.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_section_header.dart';
import 'package:yucat/presentation/components/ds_shimmer.dart';
import 'package:yucat/service_locator.dart';

/// "Food guide" swimlane — which human foods a cat can eat, by category,
/// backed by the Firestore catalogue.
///
/// Full-bleed by design: the header is inset, the lane is not, so tiles scroll
/// under both screen edges. Add it to the Home `ListView` **without** a
/// `Padding` wrapper.
class FoodGuideSection extends StatefulWidget {
  final VoidCallback onSeeAll;
  final ValueChanged<FoodGuideDisplayModel> onCategoryTap;

  const FoodGuideSection({
    super.key,
    required this.onSeeAll,
    required this.onCategoryTap,
  });

  /// Height the lane occupies — read by the Home skeleton's bone too.
  static const double laneHeight = 116;

  @override
  State<FoodGuideSection> createState() => _FoodGuideSectionState();
}

class _FoodGuideSectionState extends State<FoodGuideSection> {
  late FoodGuideBloc _bloc;
  String? _language;

  @override
  void initState() {
    super.initState();
    // A fresh factory instance — `FoodGuideBloc` is deliberately absent from
    // main.dart's MultiBlocProvider, because this section is its only consumer.
    // The repository memoizes per language, so remounting costs no round-trip.
    _bloc = sl<FoodGuideBloc>();
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
    _bloc.add(FoodGuideInitialEvent(language: language));
  }

  @override
  void dispose() {
    // This instance is ours, so closing it is required — unlike `RecipesPage`,
    // which borrows the root-owned bloc and must NOT close it.
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<FoodGuideBloc, FoodGuideState>(
      bloc: _bloc,
      builder: (context, state) {
        // Home is a discovery surface: a lane that failed or has nothing to
        // show removes itself rather than shouting.
        if (state is FoodGuideErrorState ||
            (state is FoodGuideLoadedState && state.items.isEmpty)) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
              child: DSSectionHeader(
                title: l10n.homeFoodGuideTitle,
                actionLabel: l10n.homeSeeAll,
                onAction: widget.onSeeAll,
              ),
            ),
            const SizedBox(height: DSDimens.sizeS),
            SizedBox(
              height: FoodGuideSection.laneHeight,
              child: state is FoodGuideLoadedState
                  ? ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: DSDimens.sizeL,
                      ),
                      itemCount: state.items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: DSDimens.sizeXxxs),
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return _FoodGuideTile(
                          item: item,
                          onTap: () => widget.onCategoryTap(item),
                        );
                      },
                    )
                  : const _FoodGuideLaneShimmer(),
            ),
          ],
        );
      },
    );
  }
}

class _FoodGuideTile extends StatelessWidget {
  final FoodGuideDisplayModel item;
  final VoidCallback onTap;

  const _FoodGuideTile({required this.item, required this.onTap});

  static const double _width = 82;
  static const double _tile = 74;

  @override
  Widget build(BuildContext context) {
    // Check for a URL first so a category with no photo never starts a network
    // request; the tint sits behind the image so there's no white flash.
    final hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;

    return Semantics(
      label: item.name,
      button: true,
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
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                child: hasImage
                    ? Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        width: _tile,
                        height: _tile,
                        errorBuilder: (_, __, ___) =>
                            FoodGuideEmoji(emoji: item.emoji, size: 34),
                      )
                    : FoodGuideEmoji(emoji: item.emoji, size: 34),
              ),
              const SizedBox(height: DSDimens.sizeXxs),
              Flexible(
                child: ExcludeSemantics(
                  child: Text(
                    item.name,
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

/// Tile bones while the catalogue loads. The lane's `SizedBox` clips the
/// overhang, so the row can be wider than the screen the way the real lane is.
class _FoodGuideLaneShimmer extends StatelessWidget {
  const _FoodGuideLaneShimmer();

  @override
  Widget build(BuildContext context) {
    return DSShimmer(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: DSDimens.sizeXxxs),
        itemBuilder: (_, __) => const SizedBox(
          width: _FoodGuideTile._width,
          child: Column(
            children: [
              ShimmerBone(width: 74, height: 74, radius: DSRadii.lg),
              SizedBox(height: DSDimens.sizeXxs),
              ShimmerBone(width: 52, height: 11, radius: DSRadii.sm),
            ],
          ),
        ),
      ),
    );
  }
}
