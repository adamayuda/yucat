import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_shimmer.dart';

/// Skeleton for the product detail screen — stacked card bones matching the
/// loaded body (hero, analysis, nutrition grid, cat assessment).
class ProductDetailSkeleton extends StatelessWidget {
  const ProductDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom + DSDimens.size3xl;
    return DeferredSkeleton(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          DSDimens.sizeL,
          DSDimens.sizeXs,
          DSDimens.sizeL,
          bottomInset,
        ),
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          _HeroCardBone(),
          SizedBox(height: DSDimens.sizeL),
          _AnalysisCardBone(),
          SizedBox(height: DSDimens.sizeL),
          _NutritionCardBone(),
          SizedBox(height: DSDimens.sizeL),
          _AssessmentCardBone(),
        ],
      ),
    );
  }
}

class _HeroCardBone extends StatelessWidget {
  const _HeroCardBone();

  @override
  Widget build(BuildContext context) {
    return DSCard(
      child: DSShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBone(height: 160, radius: DSRadii.lg),
            const SizedBox(height: DSDimens.sizeL),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FractionallySizedBox(
                        widthFactor: 0.7,
                        child:
                            const ShimmerBone(height: 22, radius: DSRadii.sm),
                      ),
                      const SizedBox(height: DSDimens.sizeXs),
                      FractionallySizedBox(
                        widthFactor: 0.45,
                        child:
                            const ShimmerBone(height: 14, radius: DSRadii.sm),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DSDimens.sizeS),
                const ShimmerCircle(size: 64),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisCardBone extends StatelessWidget {
  const _AnalysisCardBone();

  @override
  Widget build(BuildContext context) {
    return DSCard(
      child: DSShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FractionallySizedBox(
              widthFactor: 0.5,
              child: const ShimmerBone(height: 18, radius: DSRadii.sm),
            ),
            const SizedBox(height: DSDimens.sizeS),
            const ShimmerBone(height: 12, radius: DSRadii.sm),
            const SizedBox(height: DSDimens.sizeXs),
            const ShimmerBone(height: 12, radius: DSRadii.sm),
            const SizedBox(height: DSDimens.sizeXs),
            FractionallySizedBox(
              widthFactor: 0.7,
              child: const ShimmerBone(height: 12, radius: DSRadii.sm),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionCardBone extends StatelessWidget {
  const _NutritionCardBone();

  @override
  Widget build(BuildContext context) {
    return DSCard(
      child: DSShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FractionallySizedBox(
              widthFactor: 0.4,
              child: const ShimmerBone(height: 18, radius: DSRadii.sm),
            ),
            const SizedBox(height: DSDimens.sizeS),
            Row(
              children: const [
                Expanded(child: ShimmerBone(height: 56, radius: DSRadii.md)),
                SizedBox(width: DSDimens.sizeS),
                Expanded(child: ShimmerBone(height: 56, radius: DSRadii.md)),
                SizedBox(width: DSDimens.sizeS),
                Expanded(child: ShimmerBone(height: 56, radius: DSRadii.md)),
              ],
            ),
            const SizedBox(height: DSDimens.sizeS),
            Row(
              children: const [
                Expanded(child: ShimmerBone(height: 56, radius: DSRadii.md)),
                SizedBox(width: DSDimens.sizeS),
                Expanded(child: ShimmerBone(height: 56, radius: DSRadii.md)),
                SizedBox(width: DSDimens.sizeS),
                Expanded(child: ShimmerBone(height: 56, radius: DSRadii.md)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AssessmentCardBone extends StatelessWidget {
  const _AssessmentCardBone();

  @override
  Widget build(BuildContext context) {
    return DSCard(
      child: DSShimmer(
        child: Row(
          children: [
            const ShimmerCircle(size: 44),
            const SizedBox(width: DSDimens.sizeS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FractionallySizedBox(
                    widthFactor: 0.6,
                    child: const ShimmerBone(height: 16, radius: DSRadii.sm),
                  ),
                  const SizedBox(height: DSDimens.sizeXs),
                  const ShimmerBone(height: 12, radius: DSRadii.sm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
