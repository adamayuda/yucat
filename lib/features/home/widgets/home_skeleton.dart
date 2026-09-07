import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/home/widgets/food_guide_section.dart';
import 'package:yucat/features/recipes/presentation/widgets/recipe_poster_card.dart';
import 'package:yucat/presentation/components/ds_bottom_nav.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_shimmer.dart';

/// Skeleton for the Home dashboard load — the blue header, the two swimlane
/// bones and the mission panel, mirroring `HomeDashboardPage`.
/// Distinct from the multi-step scan animation (`HomeLoadingWidget`).
///
/// ⚠️ Every dimension in `_ScanHeaderBone` mirrors `HomeScanHeader`. Change one
/// and change the other, or the loading→loaded swap jumps.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return DeferredSkeleton(
      child: SafeArea(
        // Matches HomeDashboardPage: the header bone bleeds under the status
        // bar and adds the inset itself, so the two line up and the
        // loading→loaded swap doesn't jump.
        top: false,
        bottom: false,
        child: ListView(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).padding.bottom + kFloatingNavClearance,
          ),
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            // Full-bleed, like the real header — the horizontal inset lives on
            // the individual bones below rather than on the list.
            _ScanHeaderBone(),
            SizedBox(height: DSDimens.sizeL),
            _Inset(child: _FoodGuideLaneBone()),
            SizedBox(height: DSDimens.sizeL),
            _Inset(child: _RecipeLaneBone()),
            SizedBox(height: DSDimens.sizeL),
            _Inset(child: _MissionBone()),
          ],
        ),
      ),
    );
  }
}

/// The page gutter the list itself no longer applies.
class _Inset extends StatelessWidget {
  final Widget child;

  const _Inset({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
      child: child,
    );
  }
}

/// Mirrors `HomeScanHeader`: the blue slab with a search pill, two copy lines
/// and the CTA. Painted in `tintBlueSoft` rather than the live gradient — a
/// skeleton states the shape, not the finish.
class _ScanHeaderBone extends StatelessWidget {
  const _ScanHeaderBone();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DSColors.tintBlueSoft,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(DSRadii.xl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        DSDimens.sizeL,
        MediaQuery.of(context).padding.top + DSDimens.sizeS,
        DSDimens.sizeL,
        DSDimens.sizeS,
      ),
      child: const DSShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBone(height: 56, radius: DSRadii.pill),
            SizedBox(height: DSDimens.sizeS),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FractionallySizedBox(
                        widthFactor: 0.5,
                        child: ShimmerBone(height: 12, radius: DSRadii.sm),
                      ),
                      SizedBox(height: DSDimens.sizeXs),
                      ShimmerBone(height: 22, radius: DSRadii.sm),
                      SizedBox(height: DSDimens.sizeXxs),
                      FractionallySizedBox(
                        widthFactor: 0.75,
                        child: ShimmerBone(height: 22, radius: DSRadii.sm),
                      ),
                      SizedBox(height: DSDimens.sizeXs),
                      FractionallySizedBox(
                        widthFactor: 0.6,
                        child: ShimmerBone(height: 14, radius: DSRadii.sm),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: DSDimens.sizeS),
                ShimmerBone(width: 88, height: 88, radius: DSRadii.md),
              ],
            ),
            SizedBox(height: DSDimens.sizeS),
            ShimmerBone(height: 52, radius: DSRadii.pill),
          ],
        ),
      ),
    );
  }
}

/// Mirrors `FoodGuideSection`: a section title over a row of photo tiles.
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
