import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_shimmer.dart';

/// Skeleton for the paywall load — mirrors `PaywallLoadedWidget` (full-bleed
/// hero, two plan cards, value props, laurel stats, fixed CTA) on the same white
/// surface so there's no color flash when offerings resolve. The white
/// background paints immediately; only the bones are deferred.
class PaywallSkeleton extends StatelessWidget {
  const PaywallSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DSColors.surfaceCard,
      child: DeferredSkeleton(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(bottom: 168),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Full-bleed hero bone (edge-to-edge, under the status bar).
                const ShimmerBone(height: 280, radius: 0),
                const SizedBox(height: DSDimens.sizeL),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
                  child: DSShimmer(
                    child: Column(
                      children: [
                        // Title + subtitle.
                        const ShimmerBone(
                          width: 180,
                          height: 26,
                          radius: DSRadii.sm,
                        ),
                        const SizedBox(height: DSDimens.sizeS),
                        const ShimmerBone(
                          width: 240,
                          height: 14,
                          radius: DSRadii.sm,
                        ),
                        const SizedBox(height: DSDimens.size3xl),
                        // Two plan cards.
                        const ShimmerBone(height: 72, radius: DSRadii.xl),
                        const SizedBox(height: DSDimens.sizeXs),
                        const ShimmerBone(height: 72, radius: DSRadii.xl),
                        const SizedBox(height: DSDimens.size3xl),
                        // Value props.
                        for (var i = 0; i < 3; i++) ...[
                          if (i > 0) const SizedBox(height: DSDimens.sizeS),
                          Row(
                            children: [
                              const ShimmerBone(
                                width: 24,
                                height: 24,
                                radius: DSRadii.sm,
                              ),
                              const SizedBox(width: DSDimens.sizeS),
                              Expanded(
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: 0.7,
                                  child: const ShimmerBone(
                                    height: 14,
                                    radius: DSRadii.sm,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: DSDimens.size3xl),
                        // Laurel stats.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            _StatBone(),
                            _StatBone(),
                            _StatBone(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Fixed bottom CTA bone.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DSDimens.sizeL,
                    DSDimens.sizeS,
                    DSDimens.sizeL,
                    DSDimens.sizeS,
                  ),
                  child: DSShimmer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const ShimmerBone(height: 56, radius: DSRadii.pill),
                        const SizedBox(height: DSDimens.sizeXs),
                        const ShimmerBone(
                          width: 200,
                          height: 12,
                          radius: DSRadii.sm,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBone extends StatelessWidget {
  const _StatBone();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ShimmerBone(width: 48, height: 24, radius: DSRadii.sm),
        SizedBox(height: DSDimens.sizeXs),
        ShimmerBone(width: 64, height: 12, radius: DSRadii.sm),
      ],
    );
  }
}
