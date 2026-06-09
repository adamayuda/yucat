import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_bottom_nav.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_shimmer.dart';
import 'package:yucat/presentation/components/skeletons/product_list_skeleton.dart';

/// Skeleton for the Home dashboard load — header, scan-hero card, active-cat
/// snapshot, and saved-products preview bones, mirroring `HomeDashboardPage`.
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
            _HeaderBone(),
            SizedBox(height: DSDimens.sizeL),
            _ScanHeroBone(),
            SizedBox(height: DSDimens.sizeM),
            _SnapshotBone(),
            SizedBox(height: DSDimens.sizeL),
            _SavedPreviewBone(),
          ],
        ),
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
          const ShimmerCircle(size: 48),
          const SizedBox(width: DSDimens.sizeS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBone(width: 120, height: 20, radius: DSRadii.sm),
                const SizedBox(height: DSDimens.sizeXxs),
                FractionallySizedBox(
                  widthFactor: 0.6,
                  child: const ShimmerBone(height: 13, radius: DSRadii.sm),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanHeroBone extends StatelessWidget {
  const _ScanHeroBone();

  @override
  Widget build(BuildContext context) {
    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: DSShimmer(
        child: Row(
          children: [
            const ShimmerBone(width: 64, height: 64, radius: DSRadii.lg),
            const SizedBox(width: DSDimens.sizeS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FractionallySizedBox(
                    widthFactor: 0.55,
                    child: const ShimmerBone(height: 20, radius: DSRadii.sm),
                  ),
                  const SizedBox(height: DSDimens.sizeXs),
                  FractionallySizedBox(
                    widthFactor: 0.7,
                    child: const ShimmerBone(height: 13, radius: DSRadii.sm),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SnapshotBone extends StatelessWidget {
  const _SnapshotBone();

  @override
  Widget build(BuildContext context) {
    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: DSShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ShimmerCircle(size: 44),
                const SizedBox(width: DSDimens.sizeS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FractionallySizedBox(
                        widthFactor: 0.45,
                        child:
                            const ShimmerBone(height: 16, radius: DSRadii.sm),
                      ),
                      const SizedBox(height: DSDimens.sizeXs),
                      FractionallySizedBox(
                        widthFactor: 0.3,
                        child:
                            const ShimmerBone(height: 12, radius: DSRadii.sm),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSDimens.sizeS),
            const ShimmerBone(height: 12, radius: DSRadii.sm),
          ],
        ),
      ),
    );
  }
}

class _SavedPreviewBone extends StatelessWidget {
  const _SavedPreviewBone();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        DSShimmer(
          child: ShimmerBone(width: 140, height: 18, radius: DSRadii.sm),
        ),
        SizedBox(height: DSDimens.sizeS),
        ProductRowSkeleton(),
        SizedBox(height: DSDimens.sizeXs),
        ProductRowSkeleton(),
      ],
    );
  }
}
