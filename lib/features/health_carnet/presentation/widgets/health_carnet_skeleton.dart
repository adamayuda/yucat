import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_shimmer.dart';

/// Loading placeholder mirroring the loaded layout: header, two stat tiles, the
/// segmented control, then due-card bones.
///
/// ⚠️ A **`ListView` with `NeverScrollableScrollPhysics`**, not a `Column` —
/// matching `CatDetailSkeleton`. The bones add up to more than a short screen
/// can show, and a `Column` inside the page's `Expanded` overflows rather than
/// clipping. A skeleton must never be the thing that throws a layout error.
class HealthCarnetSkeleton extends StatelessWidget {
  const HealthCarnetSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return DeferredSkeleton(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          DSDimens.sizeL,
          DSDimens.sizeS,
          DSDimens.sizeL,
          DSDimens.size4xl,
        ),
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          SizedBox(height: DSDimens.sizeS),
          _HeaderBone(),
          SizedBox(height: DSDimens.sizeL),
          _StatTilesBone(),
          SizedBox(height: DSDimens.sizeS),
          _SegmentedBone(),
          SizedBox(height: DSDimens.sizeS),
          _DueCardBone(),
          SizedBox(height: DSDimens.sizeS),
          _DueCardBone(),
          SizedBox(height: DSDimens.sizeS),
          _DueCardBone(),
        ],
      ),
    );
  }
}

class _HeaderBone extends StatelessWidget {
  const _HeaderBone();

  @override
  Widget build(BuildContext context) {
    return DSShimmer(
      child: Row(
        children: [
          const ShimmerCircle(size: 56),
          const SizedBox(width: DSDimens.sizeXs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              ShimmerBone(width: 180, height: 22, radius: DSRadii.sm),
              SizedBox(height: DSDimens.sizeXxs),
              ShimmerBone(width: 130, height: 14, radius: DSRadii.sm),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTilesBone extends StatelessWidget {
  const _StatTilesBone();

  @override
  Widget build(BuildContext context) {
    return DSShimmer(
      child: Row(
        children: const [
          Expanded(child: ShimmerBone(height: 92, radius: DSRadii.lg)),
          SizedBox(width: DSDimens.sizeXs),
          Expanded(child: ShimmerBone(height: 92, radius: DSRadii.lg)),
        ],
      ),
    );
  }
}

class _SegmentedBone extends StatelessWidget {
  const _SegmentedBone();

  @override
  Widget build(BuildContext context) {
    return const DSShimmer(
      child: ShimmerBone(height: 44, radius: DSRadii.pill),
    );
  }
}

class _DueCardBone extends StatelessWidget {
  const _DueCardBone();

  @override
  Widget build(BuildContext context) {
    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: DSShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBone(width: 44, height: 44, radius: DSRadii.md),
                const SizedBox(width: DSDimens.sizeXs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      ShimmerBone(width: 160, height: 16, radius: DSRadii.sm),
                      SizedBox(height: DSDimens.sizeXxs),
                      ShimmerBone(width: 120, height: 12, radius: DSRadii.sm),
                      SizedBox(height: DSDimens.sizeXxxs),
                      ShimmerBone(height: 12, radius: DSRadii.sm),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSDimens.sizeXs),
            Row(
              children: const [
                Expanded(
                  flex: 3,
                  child: ShimmerBone(height: 40, radius: DSRadii.pill),
                ),
                SizedBox(width: DSDimens.sizeXxs),
                Expanded(
                  flex: 2,
                  child: ShimmerBone(height: 40, radius: DSRadii.pill),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
