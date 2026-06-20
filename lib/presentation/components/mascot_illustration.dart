import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';

/// Playful state illustration shared by loading / empty / error views.
///
/// A cat mascot SVG sits on a soft tinted circular halo, framed by a few
/// scattered, twinkling stars. When [animate] is true the cat gently bobs and
/// the stars pulse — the same native motion vocabulary used by the home scan
/// loader (`home_loading_page.dart`). Replaces the legacy raster GIFs; state
/// views never use `.gif` assets.
class MascotIllustration extends StatefulWidget {
  /// Full cat-figure SVG, e.g. `assets/images/cat-thinking.svg`.
  final String mascotAsset;

  /// Halo color — pick a section tint that matches the state's mood.
  final Color tint;

  /// Diameter of the tinted halo (the mascot is inset within it).
  final double size;

  /// When false, renders a static frame (no bob / twinkle).
  final bool animate;

  const MascotIllustration({
    super.key,
    required this.mascotAsset,
    this.tint = DSColors.tintLavender,
    this.size = 180,
    this.animate = true,
  });

  @override
  State<MascotIllustration> createState() => _MascotIllustrationState();
}

class _MascotIllustrationState extends State<MascotIllustration>
    with TickerProviderStateMixin {
  late final AnimationController _bob;
  late final AnimationController _twinkle;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _twinkle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (widget.animate) {
      _bob.repeat(reverse: true);
      _twinkle.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _bob.dispose();
    _twinkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    // The mascot overflows the halo slightly so it reads as sitting in front
    // of it rather than trapped inside the circle.
    final mascotSize = size * 0.82;

    Widget mascot = SvgPicture.asset(
      widget.mascotAsset,
      width: mascotSize,
      height: mascotSize,
      fit: BoxFit.contain,
    );
    if (widget.animate) {
      mascot = AnimatedBuilder(
        animation: _bob,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, -6 * _bob.value),
          child: child,
        ),
        child: mascot,
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: widget.tint,
              shape: BoxShape.circle,
            ),
          ),
          ExcludeSemantics(child: mascot),
          _Star(
            asset: 'star-sharp.svg',
            color: DSColors.starGold,
            starSize: size * 0.16,
            top: size * 0.04,
            left: size * 0.02,
            rotation: 0.2,
            twinkle: widget.animate ? _twinkle : null,
          ),
          _Star(
            asset: 'star-round.svg',
            color: DSColors.starCyan,
            starSize: size * 0.11,
            top: size * 0.16,
            right: size * 0.0,
            rotation: -0.3,
            twinkle: widget.animate ? _twinkle : null,
            phaseOffset: true,
          ),
          _Star(
            asset: 'star-round.svg',
            color: DSColors.starCyan,
            starSize: size * 0.1,
            bottom: size * 0.08,
            right: size * 0.08,
            rotation: -0.2,
            twinkle: widget.animate ? _twinkle : null,
          ),
        ],
      ),
    );
  }
}

/// A scattered, optionally twinkling decorative star (mirrors the home loader).
class _Star extends StatelessWidget {
  const _Star({
    required this.asset,
    required this.color,
    required this.starSize,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.rotation = 0,
    this.twinkle,
    this.phaseOffset = false,
  });

  final String asset;
  final Color color;
  final double starSize;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double rotation;
  final Animation<double>? twinkle;
  final bool phaseOffset;

  @override
  Widget build(BuildContext context) {
    Widget star = Transform.rotate(
      angle: rotation,
      child: SvgPicture.asset(
        'assets/images/$asset',
        width: starSize,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );

    final twinkle = this.twinkle;
    if (twinkle != null) {
      star = AnimatedBuilder(
        animation: twinkle,
        builder: (context, child) {
          final v = phaseOffset ? 1 - twinkle.value : twinkle.value;
          final scale = 0.85 + 0.15 * v;
          return Opacity(
            opacity: 0.55 + 0.45 * v,
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: star,
      );
    }

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: ExcludeSemantics(child: star),
    );
  }
}
