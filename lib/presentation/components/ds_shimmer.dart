import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yucat/config/themes/theme.dart';

/// Delays a skeleton's appearance so fast (cached) loads don't flash it. Renders
/// nothing for [delay]; if still mounted afterwards, fades the skeleton in.
///
/// Wrap a screen skeleton with this so a load that finishes within ~a few frames
/// swaps straight to content with no visible "blink".
class DeferredSkeleton extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const DeferredSkeleton({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 150),
  });

  @override
  State<DeferredSkeleton> createState() => _DeferredSkeletonState();
}

class _DeferredSkeletonState extends State<DeferredSkeleton> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 220),
      child: _visible ? widget.child : const SizedBox.shrink(),
    );
  }
}

/// Wraps a skeleton subtree in the design-system shimmer sweep. Place real
/// (white) [DSCard]s *outside* this wrapper and only the grey bones inside, so
/// cards keep their surface and shadow while the bones shimmer.
class DSShimmer extends StatelessWidget {
  final Widget child;

  const DSShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: DSColors.tintAsh,
      highlightColor: DSColors.surfaceCard,
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}

/// A single rounded placeholder block. The [DSShimmer] gradient paints over it.
class ShimmerBone extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const ShimmerBone({
    super.key,
    this.width,
    required this.height,
    this.radius = DSRadii.md,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: DSColors.tintAsh,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Circular placeholder for avatars / thumbnails.
class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: DSColors.tintAsh,
        shape: BoxShape.circle,
      ),
    );
  }
}
