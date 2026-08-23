import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/home/widgets/food_guide_section.dart';
import 'package:yucat/features/recipes/presentation/widgets/recipe_poster_card.dart';
import 'package:yucat/presentation/components/ds_bottom_nav.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_shimmer.dart';

/// Skeleton for the Home dashboard load — search bar, news card, the two
/// swimlane bones and the mission panel, mirroring `HomeDashboardPage`.
/// Distinct from the multi-step scan animation (`HomeLoadingWidget`).
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return DeferredSkeleton(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            DSDimens.sizeL,
            DSDimens.sizeS,
            DSDimens.sizeL,
            MediaQuery.of(context).padding.bottom + kFloatingNavClearance,
          ),
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _SearchBarBone(),
            SizedBox(height: DSDimens.sizeL),
            _NewsCardBone(),
            SizedBox(height: DSDimens.sizeL),
            _FoodGuideLaneBone(),
            SizedBox(height: DSDimens.sizeL),
            _RecipeLaneBone(),
            SizedBox(height: DSDimens.sizeL),
            _MissionBone(),
          ],
        ),
      ),
    );
  }
}

class _SearchBarBone extends StatelessWidget {
  const _SearchBarBone();

  @override
  Widget build(BuildContext context) {
    return const DSShimmer(
      child: ShimmerBone(
        height: 56,
        radius: DSRadii.pill,
      ),
    );
  }
}

/// Mirrors `HomeNewsCard`: eyebrow, headline, body and a square thumbnail.
class _NewsCardBone extends StatelessWidget {
  const _NewsCardBone();

  @override
  Widget build(BuildContext context) {
    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: DSShimmer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FractionallySizedBox(
                    widthFactor: 0.55,
                    child: ShimmerBone(height: 12, radius: DSRadii.sm),
                  ),
                  const SizedBox(height: DSDimens.sizeS),
                  const ShimmerBone(height: 20, radius: DSRadii.sm),
                  const SizedBox(height: DSDimens.sizeXxs),
                  const FractionallySizedBox(
                    widthFactor: 0.8,
                    child: ShimmerBone(height: 20, radius: DSRadii.sm),
                  ),
                  const SizedBox(height: DSDimens.sizeXs),
                  const FractionallySizedBox(
                    widthFactor: 0.65,
                    child: ShimmerBone(height: 13, radius: DSRadii.sm),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DSDimens.sizeS),
            const ShimmerBone(width: 88, height: 88, radius: DSRadii.lg),
          ],
        ),
      ),
    );
  }
}

/// Mirrors `FoodGuideSection`: a section title over a row of emoji tiles.
class _FoodGuideLaneBone extends StatelessWidget {
  const _FoodGuideLaneBone();

  @override
  Widget build(BuildContext context) {
    return DSShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBone(width: 180, height: 26, radius: DSRadii.sm),
          const SizedBox(height: DSDimens.sizeS),
          // The real lane scrolls and runs off-screen; the bone can't, so it
          // clips instead of overflowing on a narrow device.
          _LaneStrip(
            height: FoodGuideSection.laneHeight,
            children: [
              for (var i = 0; i < 4; i++) ...[
                if (i > 0) const SizedBox(width: DSDimens.sizeXxxs),
                const Column(
                  children: [
                    ShimmerBone(width: 74, height: 74, radius: DSRadii.lg),
                    SizedBox(height: DSDimens.sizeXxs),
                    ShimmerBone(width: 52, height: 11, radius: DSRadii.sm),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Mirrors `HomeRecipesSection`: a section title over poster cards.
class _RecipeLaneBone extends StatelessWidget {
  const _RecipeLaneBone();

  @override
  Widget build(BuildContext context) {
    return DSShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBone(width: 210, height: 26, radius: DSRadii.sm),
          const SizedBox(height: DSDimens.sizeS),
          // Two 208px cards plus their gap are wider than the padded list, the
          // same way the real lane overflows the screen — clip, don't overflow.
          _LaneStrip(
            height: RecipePosterCard.laneHeight,
            children: [
              for (var i = 0; i < 2; i++) ...[
                if (i > 0) const SizedBox(width: DSDimens.sizeS),
                const ShimmerBone(
                  width: RecipePosterCard.width,
                  height: RecipePosterCard.laneHeight,
                  radius: DSRadii.xl,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// A swimlane bone's row of tiles. The real lanes are horizontally scrollable
/// and full-bleed, so their content is *meant* to run past the screen edge —
/// but the skeleton's list is padded and doesn't scroll, so a bare `Row` throws
/// a horizontal overflow. Clipping reproduces the peek without the error.
class _LaneStrip extends StatelessWidget {
  final double height;
  final List<Widget> children;

  const _LaneStrip({required this.height, required this.children});

  @override
  Widget build(BuildContext context) {
    // The explicit height matches the real lane's `SizedBox` — without it the
    // OverflowBox inherits the list's unbounded height and can't lay out.
    return SizedBox(
      height: height,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          maxWidth: double.infinity,
          child: Row(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }
}

/// Mirrors `HomeMissionCard`: a title over three body lines.
class _MissionBone extends StatelessWidget {
  const _MissionBone();

  @override
  Widget build(BuildContext context) {
    return DSCard(
      background: DSColors.tintMist,
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: DSShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBone(width: 150, height: 24, radius: DSRadii.sm),
            const SizedBox(height: DSDimens.sizeXs),
            const ShimmerBone(height: 14, radius: DSRadii.sm),
            const SizedBox(height: DSDimens.sizeXxs),
            const ShimmerBone(height: 14, radius: DSRadii.sm),
            const SizedBox(height: DSDimens.sizeXxs),
            const FractionallySizedBox(
              widthFactor: 0.6,
              child: ShimmerBone(height: 14, radius: DSRadii.sm),
            ),
          ],
        ),
      ),
    );
  }
}
