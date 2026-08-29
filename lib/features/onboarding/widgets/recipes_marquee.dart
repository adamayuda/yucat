import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

/// One photo in the collage.
///
/// [aspect] is the asset's own width/height, hardcoded so column heights are
/// known at layout time — measuring would mean decoding the image first, which
/// costs a frame and makes the first paint jump.
class _Tile {
  final String asset;
  final double aspect;

  const _Tile(this.asset, this.aspect);
}

/// The decorative collage on onboarding phase 2: three columns of photos
/// drifting continuously — outer columns down, middle column up.
///
/// ⚠️ This is the app's only perpetual animation on a **long-lived** page. The
/// others (`MascotIllustration`, the scanner reticle, `HomeLoadingPage`) all sit
/// on ephemeral screens and stop by being unmounted. Here the onboarding
/// `PageView` keeps neighbouring pages mounted and does **not** wrap them in a
/// disabled `TickerMode`, so the animation must be paused explicitly — hence
/// [active]. See `lib/features/onboarding/README.md` §5.
class RecipesMarquee extends StatefulWidget {
  /// Whether this is the currently-visible onboarding phase. False stops the
  /// controller so an off-screen page isn't burning frames.
  final bool active;

  const RecipesMarquee({super.key, required this.active});

  static const List<_Tile> _left = [
    _Tile('assets/images/collage-tuna-biscuits.jpg', 360 / 540),
    _Tile('assets/images/collage-cat-drinking.jpg', 1),
    _Tile('assets/images/collage-pate-bites.jpg', 1),
    _Tile('assets/images/collage-litter-box.jpg', 360 / 240),
  ];

  static const List<_Tile> _middle = [
    _Tile('assets/images/collage-salmon-pumpkin.jpg', 360 / 480),
    _Tile('assets/images/collage-frozen-tuna-bites.jpg', 1),
    _Tile('assets/images/collage-dry-food.jpg', 360 / 240),
    _Tile('assets/images/collage-shredded-zucchini.jpg', 1),
  ];

  static const List<_Tile> _right = [
    _Tile('assets/images/collage-senior-cat-bowl.jpg', 360 / 240),
    _Tile('assets/images/collage-tuna-mini-cake.jpg', 1),
    _Tile('assets/images/collage-fish-treats.jpg', 360 / 448),
    _Tile('assets/images/collage-overweight-cat.jpg', 1),
  ];

  /// Every asset the collage paints, for `precacheImage` — decoding twelve
  /// photos on the frame the page slides in is exactly the jank the proof-chart
  /// Lottie is pre-warmed to avoid.
  static List<String> get assets => [
    for (final tile in [..._left, ..._middle, ..._right]) tile.asset,
  ];

  @override
  State<RecipesMarquee> createState() => _RecipesMarqueeState();
}

class _RecipesMarqueeState extends State<RecipesMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// One full cycle. Deliberately long — this is ambient drift, not motion the
  /// user should track. Not a `DSMotion` token: those cap at 400ms and describe
  /// transitions, so every looping animation in the app uses a raw literal.
  static const _cycle = Duration(seconds: 40);

  /// Gap between tiles, and between columns.
  static const double _gap = DSDimens.sizeXxs;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _cycle);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Here rather than initState: the reduced-motion check reads MediaQuery.
    _syncPlayback();
  }

  @override
  void didUpdateWidget(RecipesMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) _syncPlayback();
  }

  void _syncPlayback() {
    // Respect the OS "reduce motion" setting — a perpetual drifting backdrop is
    // precisely what it exists to suppress. The collage still renders, just
    // still. Nothing else in the app reads this yet.
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final shouldRun = widget.active && !reduceMotion;

    if (shouldRun && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldRun && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columnWidth = (constraints.maxWidth - _gap * 2) / 3;
          // stretch so each column gets a tight height and its Stack fills the
          // box; with loose constraints a Stack of only positioned children
          // collapses to zero height.
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MarqueeColumn(
                tiles: RecipesMarquee._left,
                width: columnWidth,
                progress: _controller,
                down: true,
                phase: 0,
              ),
              const SizedBox(width: _gap),
              _MarqueeColumn(
                tiles: RecipesMarquee._middle,
                width: columnWidth,
                progress: _controller,
                down: false,
                phase: 0.37,
              ),
              const SizedBox(width: _gap),
              _MarqueeColumn(
                tiles: RecipesMarquee._right,
                width: columnWidth,
                progress: _controller,
                down: true,
                phase: 0.71,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MarqueeColumn extends StatelessWidget {
  final List<_Tile> tiles;
  final double width;
  final Animation<double> progress;

  /// Direction of travel. All three columns share one controller, so they
  /// complete a cycle together — but each column's cycle is a different number
  /// of pixels, which is what makes them drift at visibly different speeds.
  final bool down;

  /// Fraction of a cycle to offset this column by, so the three don't start
  /// their loops aligned.
  final double phase;

  const _MarqueeColumn({
    required this.tiles,
    required this.width,
    required this.progress,
    required this.down,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    // Height of one copy of the tile list, gaps included. Translating by
    // exactly this puts the layout back where it started, which is what makes
    // the wrap invisible.
    final cycleHeight = tiles.fold<double>(
      0,
      (sum, tile) => sum + width / tile.aspect + _RecipesMarqueeState._gap,
    );

    // Rendered twice: as one copy scrolls out, the other is already covering
    // the space it left.
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var copy = 0; copy < 2; copy++)
          for (final tile in tiles)
            Padding(
              padding: const EdgeInsets.only(
                bottom: _RecipesMarqueeState._gap,
              ),
              child: SizedBox(
                width: width,
                height: width / tile.aspect,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DSRadii.lg),
                  child: Image.asset(
                    tile.asset,
                    fit: BoxFit.cover,
                    // The assets ship at 360px wide; decode no larger.
                    cacheWidth: 360,
                  ),
                ),
              ),
            ),
      ],
    );

    return SizedBox(
      width: width,
      // 24 images repainting every frame: keep them off the rest of the
      // screen's layer.
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: progress,
          // `content` is passed as `child` so the twelve Image widgets are
          // built once, not rebuilt 60 times a second.
          child: content,
          builder: (context, child) {
            final t = (progress.value + phase) % 1.0;
            final dy = down ? (t - 1) * cycleHeight : -t * cycleHeight;
            // Stack + Positioned rather than Transform.translate: the content
            // is taller than the box by design, and a Positioned child with
            // only `top` set is free to overflow without a layout error. The
            // Stack's default hardEdge clip keeps it inside the column.
            return Stack(
              children: [
                Positioned(top: dy, left: 0, right: 0, child: child!),
              ],
            );
          },
        ),
      ),
    );
  }
}
