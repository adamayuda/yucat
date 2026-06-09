import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_shimmer.dart';

/// Skeleton row mirroring `ProductRowCard` / `CatSummaryCard`: a thumbnail
/// (square or circular), a title + subtitle line, and a small pill. White card
/// surface kept; only the bones shimmer.
class ProductRowSkeleton extends StatelessWidget {
  /// Render the leading thumbnail as a circle (used for cat avatars).
  final bool circularThumb;

  const ProductRowSkeleton({super.key, this.circularThumb = false});

  @override
  Widget build(BuildContext context) {
    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: DSShimmer(
        child: Row(
          children: [
            if (circularThumb)
              const ShimmerCircle(size: 64)
            else
              const ShimmerBone(width: 64, height: 64, radius: DSRadii.lg),
            const SizedBox(width: DSDimens.sizeS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FractionallySizedBox(
                    widthFactor: 0.7,
                    child: const ShimmerBone(height: 16, radius: DSRadii.sm),
                  ),
                  const SizedBox(height: DSDimens.sizeXxs),
                  FractionallySizedBox(
                    widthFactor: 0.45,
                    child: const ShimmerBone(height: 13, radius: DSRadii.sm),
                  ),
                  const SizedBox(height: DSDimens.sizeXxs),
                  const ShimmerBone(width: 92, height: 22, radius: DSRadii.pill),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A non-scrolling list of [ProductRowSkeleton]s, sharing the loaded list's
/// padding so the swap to real content doesn't jump.
class ProductListSkeleton extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final int itemCount;
  final bool circularThumb;

  const ProductListSkeleton({
    super.key,
    required this.padding,
    this.itemCount = 6,
    this.circularThumb = false,
  });

  @override
  Widget build(BuildContext context) {
    return DeferredSkeleton(
      child: ListView.separated(
        padding: padding,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: DSDimens.sizeXs),
        itemBuilder: (_, __) =>
            ProductRowSkeleton(circularThumb: circularThumb),
      ),
    );
  }
}
