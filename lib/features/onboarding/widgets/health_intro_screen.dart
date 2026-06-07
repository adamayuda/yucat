import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

/// Bridge screen into the cat-create wizard — frames the upcoming
/// questionnaire as a quick conversation about the cat's health.
class HealthIntroScreen extends StatelessWidget {
  final VoidCallback onAddCat;

  const HealthIntroScreen({super.key, required this.onAddCat});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      gradient: DSGradients.onboardingHealthIntro,
      footer: DSPillButton(label: "Let's go", onPressed: onAddCat),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: DSDimens.sizeS),
              Text(
                "Now tell us\nabout your cat's\nhealth",
                textAlign: TextAlign.center,
                style: DSTextStyles.displayHero,
              ),
              const Spacer(flex: 2),
              SvgPicture.asset('assets/images/cat-thinking.svg', height: 280),
              const Spacer(flex: 1),
            ],
          ),
          // Floating thought clouds above the mascot — spaced apart and
          // staggered, the meat sitting higher than the apple.
          Positioned(
            top: 220,
            left: 28,
            child: ExcludeSemantics(
              child: SvgPicture.asset(
                'assets/images/apple-cloud.svg',
                width: 93,
              ),
            ),
          ),
          Positioned(
            top: 168,
            right: 12,
            child: ExcludeSemantics(
              child: SvgPicture.asset(
                'assets/images/meat-cloud.svg',
                width: 141,
              ),
            ),
          ),
          // Scattered, rotated question marks flanking the cat.
          const Positioned(
            top: 300,
            left: 12,
            child: _Mark(
              text: '?',
              color: Color(0xFF408AF2),
              size: 70,
              rotation: -0.32,
            ),
          ),
          Positioned(
            top: 270,
            right: 10,
            child: _Mark(
              text: '?',
              color: const Color(0xFF5FC9C1).withValues(alpha: 0.4),
              size: 40,
              rotation: 0.35,
            ),
          ),
        ],
      ),
    );
  }
}

/// A decorative colored glyph (e.g. a question mark) pinned near the mascot.
class _Mark extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  final double rotation;

  const _Mark({
    required this.text,
    required this.color,
    required this.size,
    this.rotation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Transform.rotate(
        angle: rotation,
        child: Text(
          text,
          style: DSTextStyles.displayLg.copyWith(color: color, fontSize: size),
        ),
      ),
    );
  }
}
