import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// The home dashboard's primary call-to-action. A bold, playful gradient hero:
/// a glowing QR pill, a thumbs-up cat mascot that bobs, and twinkling stars.
class ScanHeroCard extends StatefulWidget {
  final VoidCallback onTap;

  const ScanHeroCard({super.key, required this.onTap});

  @override
  State<ScanHeroCard> createState() => _ScanHeroCardState();
}

class _ScanHeroCardState extends State<ScanHeroCard>
    with TickerProviderStateMixin {
  late final AnimationController _pulse; // glow ring behind the QR pill
  late final AnimationController _bob; // mascot bob
  late final AnimationController _twinkle; // star twinkle

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _twinkle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    _bob.dispose();
    _twinkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shape = BorderRadius.circular(DSRadii.xl);

    return Container(
      decoration: BoxDecoration(
        gradient: DSGradients.homeScanCard,
        borderRadius: shape,
        boxShadow: DSShadows.e2,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Decorative twinkling stars.
              Positioned(
                top: 12,
                right: 78,
                child: _TwinkleStar(
                  asset: 'star.svg',
                  size: 20,
                  rotation: 0.2,
                  twinkle: _twinkle,
                ),
              ),
              Positioned(
                bottom: 14,
                right: 120,
                child: _TwinkleStar(
                  asset: 'star-cyan.svg',
                  size: 14,
                  rotation: -0.3,
                  twinkle: _twinkle,
                  phaseOffset: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(DSDimens.sizeL),
                child: Row(
                  children: [
                    _PulsingQrPill(pulse: _pulse),
                    const SizedBox(width: DSDimens.sizeS),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.homeScanProduct,
                            style: DSTextStyles.headlineMd,
                          ),
                          const SizedBox(height: DSDimens.sizeXxxs),
                          Text(
                            l10n.homeScanProductSubtitle,
                            style: DSTextStyles.bodyMd.copyWith(
                              color: DSColors.inkSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Reserve space so the mascot never overlaps the text.
                    const SizedBox(width: 56),
                  ],
                ),
              ),
              // Thumbs-up cat mascot, bobbing in the bottom-right corner.
              Positioned(
                right: 0,
                bottom: 0,
                child: AnimatedBuilder(
                  animation: _bob,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, -4 * _bob.value),
                    child: child,
                  ),
                  child: ExcludeSemantics(
                    child: SvgPicture.asset(
                      'assets/images/cat-thumb.svg',
                      width: 80,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dark QR pill that gently scale-pulses to draw the eye.
class _PulsingQrPill extends StatelessWidget {
  const _PulsingQrPill({required this.pulse});

  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) => Transform.scale(
        scale: 1.0 + 0.05 * pulse.value,
        child: child,
      ),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: DSColors.inkPrimary,
          borderRadius: BorderRadius.circular(DSRadii.lg),
          boxShadow: DSShadows.e2,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.qr_code_scanner_rounded,
          color: DSColors.inkInverse,
          size: 32,
        ),
      ),
    );
  }
}

/// A decorative star that pulses its scale/opacity.
class _TwinkleStar extends StatelessWidget {
  const _TwinkleStar({
    required this.asset,
    required this.size,
    required this.twinkle,
    this.rotation = 0,
    this.phaseOffset = false,
  });

  final String asset;
  final double size;
  final Animation<double> twinkle;
  final double rotation;
  final bool phaseOffset;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: twinkle,
        builder: (context, child) {
          final v = phaseOffset ? 1 - twinkle.value : twinkle.value;
          return Opacity(
            opacity: 0.55 + 0.45 * v,
            child: Transform.scale(scale: 0.85 + 0.15 * v, child: child),
          );
        },
        child: Transform.rotate(
          angle: rotation,
          child: SvgPicture.asset('assets/images/$asset', width: size),
        ),
      ),
    );
  }
}
