import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_shimmer.dart';

/// Skeleton for the cat detail screen — hero avatar + name over the completion
/// and details card bones, matching the loaded body.
class CatDetailSkeleton extends StatelessWidget {
  const CatDetailSkeleton({super.key});

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
          _HeroBone(),
          SizedBox(height: DSDimens.size3xl),
          _CompletionCardBone(),
          SizedBox(height: DSDimens.sizeS),
          _DetailsCardBone(),
        ],
      ),
    );
  }
}

class _HeroBone extends StatelessWidget {
  const _HeroBone();

  @override
  Widget build(BuildContext context) {
    return DSShimmer(
      child: Column(
        children: const [
          ShimmerCircle(size: 96),
          SizedBox(height: DSDimens.sizeS),
          ShimmerBone(width: 140, height: 22, radius: DSRadii.sm),
          SizedBox(height: DSDimens.sizeXs),
          ShimmerBone(width: 90, height: 14, radius: DSRadii.sm),
        ],
      ),
    );
  }
}

class _CompletionCardBone extends StatelessWidget {
  const _CompletionCardBone();

  @override
  Widget build(BuildContext context) {
    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: DSShimmer(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ShimmerBone(width: 150, height: 16, radius: DSRadii.sm),
                ShimmerBone(width: 40, height: 16, radius: DSRadii.sm),
              ],
            ),
            const SizedBox(height: DSDimens.sizeXs),
            const ShimmerBone(height: 8, radius: DSRadii.pill),
          ],
        ),
      ),
    );
  }
}

class _DetailsCardBone extends StatelessWidget {
  const _DetailsCardBone();

  @override
  Widget build(BuildContext context) {
    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: DSShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBone(width: 90, height: 16, radius: DSRadii.sm),
            const SizedBox(height: DSDimens.sizeS),
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(height: DSDimens.sizeS),
              Row(
                children: const [
                  Expanded(child: ShimmerBone(height: 56, radius: DSRadii.md)),
                  SizedBox(width: DSDimens.sizeS),
                  Expanded(child: ShimmerBone(height: 56, radius: DSRadii.md)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
