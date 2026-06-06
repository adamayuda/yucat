import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/onboarding_floating_button.dart';

/// Push-notification warm-up screen.
///
/// MOCK ONLY — this previews the value of alerts but does not request the
/// iOS notification permission or register for push.
// TODO(feature): wire real notification permission + push delivery.
class NotifPrimerScreen extends StatelessWidget {
  final VoidCallback onNext;

  const NotifPrimerScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8CDC6),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8CDC6),
              DSColors.tintCoral,
              Color(0xFFF3EEEC),
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Rainbow arc, full width (asset is 393×318), lifted off the
            // bottom so the light wash shows beneath it.
            Positioned(
              left: 0,
              right: 0,
              bottom: 140,
              child: ExcludeSemantics(
                child: AspectRatio(
                  aspectRatio: 393 / 318,
                  child: SvgPicture.asset(
                    'assets/images/rainbow.svg',
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ),
            // Mascot sitting low on the rainbow, feet dropping below the
            // crest, above the CTA.
            Positioned(
              left: 0,
              right: 0,
              bottom: 204,
              child: ExcludeSemantics(
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/cat-ping-notif.svg',
                    height: 270,
                  ),
                ),
              ),
            ),
            // Scattered sparkles around the header.
            const _Flower(size: 26, top: 96, right: 28),
            const _Flower(size: 18, top: 150, left: 32),
            const _Flower(size: 16, top: 250, right: 44),
            // Foreground content.
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Clear the back chip overlaid by onboarding_page.dart.
                    const SizedBox(height: 48),
                    Text(
                      "We'll keep an eye on\nyour cat's food",
                      textAlign: TextAlign.center,
                      style: DSTextStyles.displayLg,
                    ),
                    const SizedBox(height: DSDimens.sizeXxl),
                    const _NotificationStack(),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            // Bottom-anchored CTA, floated over the rainbow.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Center(
                  child: OnboardingFloatingButton(
                    label: 'Set up reminders',
                    onPressed: onNext,
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

/// Decorative sparkle pinned to the header area (fixed, behind the content).
class _Flower extends StatelessWidget {
  final double size;
  final double? top;
  final double? left;
  final double? right;

  const _Flower({
    required this.size,
    this.top,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: ExcludeSemantics(
        child: SvgPicture.asset('assets/images/flower.svg', width: size),
      ),
    );
  }
}

/// Front notification card with blank, dimmed cards peeking behind it to
/// mimic an iOS notification pile.
class _NotificationStack extends StatelessWidget {
  const _NotificationStack();

  @override
  Widget build(BuildContext context) {
    // Bottom-aligned so the blank cards peek below the front card no matter
    // its height; each one is pushed further down, inset, and more
    // transparent to read as a receding pile.
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Third (deepest) card — least opaque.
        Transform.translate(
          offset: const Offset(0, 46),
          child: _blankCard(inset: 32, opacity: 0.4),
        ),
        // Second card — more opaque.
        Transform.translate(
          offset: const Offset(0, 24),
          child: _blankCard(inset: 16, opacity: 0.8),
        ),
        const _MockNotification(),
      ],
    );
  }

  Widget _blankCard({required double inset, required double opacity}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: inset),
      child: Opacity(
        opacity: opacity,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: DSColors.surfaceCard,
            borderRadius: BorderRadius.circular(DSRadii.lg),
            boxShadow: DSShadows.e1,
          ),
        ),
      ),
    );
  }
}

class _MockNotification extends StatelessWidget {
  const _MockNotification();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeS,
        vertical: DSDimens.sizeL,
      ),
      decoration: BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.lg),
        boxShadow: DSShadows.e2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: DSColors.tintLavender,
              borderRadius: BorderRadius.circular(DSRadii.sm),
            ),
            child: const Text('🐱', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: DSDimens.sizeXs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _HeartMeter(filled: 1, total: 4),
                    const SizedBox(width: DSDimens.sizeXxs),
                    Text(
                      'Match dropped',
                      style: DSTextStyles.caption.copyWith(
                        color: DSColors.inkTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DSDimens.sizeXxxs),
                Text(
                  "Luna's food changed recipe — see the new verdict 🔍",
                  style: DSTextStyles.bodyMd.copyWith(
                    color: DSColors.inkPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Row of hearts — [filled] coral, the rest light grey — echoing the
/// reference notification's life/scan meter.
class _HeartMeter extends StatelessWidget {
  final int filled;
  final int total;

  const _HeartMeter({required this.filled, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              Icons.favorite,
              size: 13,
              color: i < filled
                  ? DSColors.coralAccent
                  : const Color(0xFFE2DFE8),
            ),
          ),
      ],
    );
  }
}
