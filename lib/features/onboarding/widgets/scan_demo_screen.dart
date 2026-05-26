import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

/// Step right after Welcome — stylised scan demo with floating verdict
/// pills. Lands the value-prop before the survey starts.
class ScanDemoScreen extends StatelessWidget {
  final VoidCallback onNext;

  const ScanDemoScreen({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      background: DSColors.surfaceCard,
      footer: DSPillButton(label: 'Next', onPressed: onNext),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          const _ScanDemoCard(),
          const SizedBox(height: DSDimens.size3xl),
          Text(
            'Scan\nany bag',
            textAlign: TextAlign.center,
            style: DSTextStyles.displayLg,
          ),
          const SizedBox(height: DSDimens.sizeS),
          Text(
            'Point your camera at any\ncat food and get a verdict',
            textAlign: TextAlign.center,
            style: DSTextStyles.bodyMd.copyWith(
              color: DSColors.inkSecondary,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _ScanDemoCard extends StatelessWidget {
  const _ScanDemoCard();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DSRadii.xl),
        color: DSColors.surfaceCard,
        boxShadow: DSShadows.e2,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.6, 0.601, 1.0],
          colors: [
            Color(0xFFEEF4F9),
            Color(0xFFD6E8C8),
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // food bag centered near the top
          const Align(
            alignment: Alignment(0, -0.55),
            child: _FoodBag(),
          ),
          // green scan corners around the bag area
          const Positioned(
            top: 18,
            left: 36,
            child: _ScanCorner(top: true, left: true),
          ),
          const Positioned(
            top: 18,
            right: 36,
            child: _ScanCorner(top: true, right: true),
          ),
          const Positioned(
            bottom: 70,
            left: 36,
            child: _ScanCorner(bottom: true, left: true),
          ),
          const Positioned(
            bottom: 70,
            right: 36,
            child: _ScanCorner(bottom: true, right: true),
          ),
          // floating verdict pills
          const Positioned(
            top: 56,
            left: 8,
            child: _VerdictPill(
              caption: 'Protein',
              value: '32%',
              tail: 'good',
              accent: DSColors.accentSuccess,
            ),
          ),
          const Positioned(
            top: 46,
            right: 6,
            child: _VerdictPill(
              caption: 'Grain',
              value: 'added',
              tail: '⚠',
              accent: DSColors.coralAccent,
            ),
          ),
          const Positioned(
            top: 110,
            right: 4,
            child: _VerdictPill(
              caption: 'For seniors',
              value: 'great fit',
              accent: DSColors.accentSuccess,
            ),
          ),
          // cat emoji at the card's bottom
          const Align(
            alignment: Alignment(0, 0.95),
            child: Text('😸', style: TextStyle(fontSize: 48)),
          ),
        ],
      ),
      ),
    );
  }
}

class _FoodBag extends StatelessWidget {
  const _FoodBag();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 130,
      decoration: BoxDecoration(
        color: const Color(0xFFFFCC66),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(8),
          bottom: Radius.circular(6),
        ),
        boxShadow: DSShadows.e2,
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              SizedBox(
                height: 22,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFFE0A040),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(6),
                child: Text(
                  'PREMIUM\nCAT FOOD',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5A3500),
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const Align(
            alignment: Alignment(0, 0.85),
            child: Text('🐟', style: TextStyle(fontSize: 30)),
          ),
        ],
      ),
    );
  }
}

class _ScanCorner extends StatelessWidget {
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  const _ScanCorner({
    this.top = false,
    this.bottom = false,
    this.left = false,
    this.right = false,
  });

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF3DBB7B);
    const stroke = 2.5;
    return SizedBox(
      width: 14,
      height: 14,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: top
                ? const BorderSide(color: color, width: stroke)
                : BorderSide.none,
            bottom: bottom
                ? const BorderSide(color: color, width: stroke)
                : BorderSide.none,
            left: left
                ? const BorderSide(color: color, width: stroke)
                : BorderSide.none,
            right: right
                ? const BorderSide(color: color, width: stroke)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _VerdictPill extends StatelessWidget {
  final String caption;
  final String value;
  final String? tail;
  final Color accent;

  const _VerdictPill({
    required this.caption,
    required this.value,
    required this.accent,
    this.tail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeXs,
        vertical: DSDimens.sizeXxxs,
      ),
      decoration: BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.md),
        boxShadow: DSShadows.e1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            caption,
            style: DSTextStyles.caption.copyWith(
              color: DSColors.inkSecondary,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: DSTextStyles.label.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (tail != null) ...[
                const SizedBox(width: 3),
                Text(
                  tail!,
                  style: DSTextStyles.label.copyWith(
                    color: DSColors.inkSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
