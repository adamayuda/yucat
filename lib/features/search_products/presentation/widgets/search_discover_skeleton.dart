import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_shimmer.dart';

/// Skeleton for the Search tab's discover state — a "Popular brands" heading
/// over a strip of brand-tile bones, mirroring `SearchDiscoverView`.
class SearchDiscoverSkeleton extends StatelessWidget {
  const SearchDiscoverSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom + 96;
    return DeferredSkeleton(
      child: DSShimmer(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            DSDimens.sizeL,
            DSDimens.sizeS,
            DSDimens.sizeL,
            bottomInset,
          ),
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const ShimmerBone(width: 160, height: 18, radius: DSRadii.sm),
            const SizedBox(height: DSDimens.sizeS),
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: DSDimens.sizeXs),
                itemBuilder: (_, __) => const ShimmerBone(
                  width: 96,
                  height: 96,
                  radius: DSRadii.lg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
