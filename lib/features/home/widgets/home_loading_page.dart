import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// Post-scan analysis screen shown while `fetchProductByImageV2` runs.
///
/// A playful, mascot-led loading state that borrows the onboarding vocabulary:
/// a colorful gradient, the cat mascot inspecting a "scanning" product card,
/// twinkling scattered stars, and a single status line that rotates through
/// light-hearted phrases. The copy loops until the backend returns and the
/// route is replaced, so it never reads as frozen.
class HomeLoadingWidget extends StatefulWidget {
  /// The just-captured photo (base64), shown under the sweeping scan line.
  final String imageBase64;

  const HomeLoadingWidget({super.key, required this.imageBase64});

  @override
  State<HomeLoadingWidget> createState() => _HomeLoadingWidgetState();
}

class _HomeLoadingWidgetState extends State<HomeLoadingWidget>
    with TickerProviderStateMixin {
  late final AnimationController _scanController; // sweeping scan line
  late final AnimationController _bobController; // mascot bob
  late final AnimationController _twinkleController; // star twinkle

  /// Decoded once; null if the base64 is empty/malformed (falls back to the
  /// placeholder label bars).
  Uint8List? _imageBytes;

  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    _decodeImage();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _startMessageCycle();
  }

  void _decodeImage() {
    if (widget.imageBase64.isEmpty) return;
    try {
      _imageBytes = base64Decode(widget.imageBase64);
    } catch (_) {
      _imageBytes = null;
    }
  }

  void _startMessageCycle() {
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      setState(() => _messageIndex++);
      _startMessageCycle();
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _bobController.dispose();
    _twinkleController.dispose();
    super.dispose();
  }

  List<String> _messages(AppLocalizations l10n) => [
        l10n.homeLoadingMsgReading,
        l10n.homeLoadingMsgSniffing,
        l10n.homeLoadingMsgMatching,
        l10n.homeLoadingMsgCrunching,
        l10n.homeLoadingMsgAlmost,
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final messages = _messages(l10n);
    final message = messages[_messageIndex % messages.length];

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: DSGradients.onboardingHealthIntro,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ScanHero(
                scan: _scanController,
                bob: _bobController,
                twinkle: _twinkleController,
                imageBytes: _imageBytes,
              ),
              const SizedBox(height: DSDimens.size3xl),
              Text(
                l10n.homeLoadingEyebrow,
                textAlign: TextAlign.center,
                style: DSTextStyles.label.copyWith(color: DSColors.inkSecondary),
              ),
              const SizedBox(height: DSDimens.sizeXxs),
              // Rotating status line — fades/slides between phrases.
              AnimatedSwitcher(
                duration: DSMotion.durMed,
                switchInCurve: DSMotion.curveDecelerate,
                switchOutCurve: DSMotion.curveDecelerate,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.25),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: Text(
                  message,
                  key: ValueKey(message),
                  textAlign: TextAlign.center,
                  style: DSTextStyles.displayLg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The "cat holding a card" illustration with the captured photo set into the
/// card and a scan line sweeping over it, framed by twinkling stars.
class _ScanHero extends StatelessWidget {
  const _ScanHero({
    required this.scan,
    required this.bob,
    required this.twinkle,
    required this.imageBytes,
  });

  final Animation<double> scan;
  final Animation<double> bob;
  final Animation<double> twinkle;
  final Uint8List? imageBytes;

  // Rendered width; height follows the SVG's aspect ratio.
  static const double _width = 270;

  // 'Illustration scan.svg' viewBox is 1266 x 1278.
  static const double _vbW = 1266;
  static const double _vbH = 1278;

  // The card <rect> within that viewBox: x=446.493 y=0 w=819 h=1177 rx=110.
  static const double _cardLeftF = 446.493 / _vbW;
  static const double _cardWF = 819 / _vbW;
  static const double _cardHF = 1177 / _vbH;
  static const double _cardRxF = 110 / _vbW;

  @override
  Widget build(BuildContext context) {
    final height = _width * _vbH / _vbW;

    // Card rect in rendered px.
    final cardLeft = _cardLeftF * _width;
    final cardW = _cardWF * _width;
    final cardH = _cardHF * height;
    final cardRx = _cardRxF * _width;

    // Inset the photo so the white card border frames it (and the holding paw,
    // drawn in front of the card, stays clear of the photo).
    final inset = cardW * 0.07;
    final photoW = cardW - inset * 2;
    final photoH = cardH - inset * 2;
    final photoRx = (cardRx - inset).clamp(0.0, cardRx);
    final bytes = imageBytes;

    return SizedBox(
      width: _width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Illustration + inset photo + scan line, bobbing together.
          AnimatedBuilder(
            animation: bob,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, -5 * bob.value),
              child: child,
            ),
            child: Stack(
              children: [
                ExcludeSemantics(
                  child: SvgPicture.asset(
                    'assets/images/Illustration scan.svg',
                    width: _width,
                    height: height,
                    fit: BoxFit.fill,
                  ),
                ),
                if (bytes != null)
                  Positioned(
                    left: cardLeft + inset,
                    top: inset,
                    width: photoW,
                    height: photoH,
                    child: _ScanPhoto(
                      bytes: bytes,
                      scan: scan,
                      radius: photoRx,
                      height: photoH,
                    ),
                  ),
              ],
            ),
          ),
          // Twinkling scattered stars near the cat / top-left.
          _Star(
            asset: 'star.svg',
            size: 26,
            top: 18,
            left: 4,
            rotation: 0.2,
            twinkle: twinkle,
          ),
          _Star(
            asset: 'star-cyan.svg',
            size: 18,
            top: 78,
            left: 52,
            rotation: -0.3,
            twinkle: twinkle,
            phaseOffset: true,
          ),
          _Star(
            asset: 'star-green.svg',
            size: 15,
            bottom: 96,
            left: 0,
            rotation: -0.2,
            twinkle: twinkle,
          ),
        ],
      ),
    );
  }
}

/// The captured photo set into the illustration's card, with a glowing scan
/// line sweeping over it.
class _ScanPhoto extends StatelessWidget {
  const _ScanPhoto({
    required this.bytes,
    required this.scan,
    required this.radius,
    required this.height,
  });

  final Uint8List bytes;
  final Animation<double> scan;
  final double radius;
  final double height;

  static const Color _accent = DSColors.coralAccent;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true),
          // Glowing scan line sweeping top → bottom over the photo.
          AnimatedBuilder(
            animation: scan,
            builder: (context, _) {
              final t = Curves.easeInOut.transform(scan.value);
              final y = t * (height - 3);
              return Positioned(
                left: 0,
                right: 0,
                top: y,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: _accent,
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.7),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// A scattered, optionally twinkling decorative star.
class _Star extends StatelessWidget {
  const _Star({
    required this.asset,
    required this.size,
    this.top,
    this.bottom,
    this.left,
    this.rotation = 0,
    this.twinkle,
    this.phaseOffset = false,
  });

  final String asset;
  final double size;
  final double? top;
  final double? bottom;
  final double? left;
  final double rotation;

  /// When provided, the star pulses its scale/opacity with this animation.
  final Animation<double>? twinkle;

  /// Inverts the twinkle phase so neighbouring stars don't pulse in sync.
  final bool phaseOffset;

  @override
  Widget build(BuildContext context) {
    Widget star = Transform.rotate(
      angle: rotation,
      child: SvgPicture.asset('assets/images/$asset', width: size),
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
      child: ExcludeSemantics(child: star),
    );
  }
}
