import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_bottom_nav.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_shimmer.dart';

/// Skeleton for the Profile hub — title, subscription card, "Your cats" card,
/// and library card bones, matching `_ProfileHub`.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

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
            _TitleBone(),
            SizedBox(height: DSDimens.sizeL),
            _SubscriptionCardBone(),
            SizedBox(height: DSDimens.sizeM),
            _YourCatsCardBone(),
            SizedBox(height: DSDimens.sizeM),
            _LibraryCardBone(),
          ],
        ),
      ),
    );
  }
}

class _TitleBone extends StatelessWidget {
  const _TitleBone();

  @override
  Widget build(BuildContext context) {
    return const DSShimmer(
      child: ShimmerBone(width: 120, height: 32, radius: DSRadii.sm),
    );
  }
}

class _SubscriptionCardBone extends StatelessWidget {
  const _SubscriptionCardBone();

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
                const ShimmerBone(width: 44, height: 44, radius: DSRadii.md),
                const SizedBox(width: DSDimens.sizeS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FractionallySizedBox(
                        widthFactor: 0.4,
                        child:
                            const ShimmerBone(height: 16, radius: DSRadii.sm),
                      ),
                      const SizedBox(height: DSDimens.sizeXs),
                      FractionallySizedBox(
                        widthFactor: 0.6,
                        child:
                            const ShimmerBone(height: 13, radius: DSRadii.sm),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DSDimens.sizeL),
            const ShimmerBone(height: 14, radius: DSRadii.sm),
            const SizedBox(height: DSDimens.sizeL),
            const ShimmerBone(height: 14, radius: DSRadii.sm),
          ],
        ),
      ),
    );
  }
}

class _YourCatsCardBone extends StatelessWidget {
  const _YourCatsCardBone();

  @override
  Widget build(BuildContext context) {
    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: DSShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBone(width: 90, height: 16, radius: DSRadii.sm),
            const SizedBox(height: DSDimens.sizeS),
            Row(
              children: const [
                ShimmerCircle(size: 56),
                SizedBox(width: DSDimens.sizeS),
                ShimmerCircle(size: 56),
                SizedBox(width: DSDimens.sizeS),
                ShimmerCircle(size: 56),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryCardBone extends StatelessWidget {
  const _LibraryCardBone();

  @override
  Widget build(BuildContext context) {
    return DSCard(
      child: DSShimmer(
        child: Column(
          children: const [
            _LibraryRowBone(),
            SizedBox(height: DSDimens.sizeL),
            _LibraryRowBone(),
          ],
        ),
      ),
    );
  }
}

class _LibraryRowBone extends StatelessWidget {
  const _LibraryRowBone();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const ShimmerBone(width: 36, height: 36, radius: DSRadii.md),
        const SizedBox(width: DSDimens.sizeS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FractionallySizedBox(
                widthFactor: 0.45,
                child: const ShimmerBone(height: 15, radius: DSRadii.sm),
              ),
              const SizedBox(height: DSDimens.sizeXs),
              FractionallySizedBox(
                widthFactor: 0.3,
                child: const ShimmerBone(height: 12, radius: DSRadii.sm),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
