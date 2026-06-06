import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

class ProfileIntroScreen extends StatelessWidget {
  final VoidCallback onNext;

  static const Color _background = Color(0xFFEFEEF5);
  static const Color _quoteSurface = Color(0xFFE5E4EB);

  const ProfileIntroScreen({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      background: _background,
      footer: DSPillButton(label: 'Next', onPressed: onNext),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 2),
          // Upper-left paw
          Align(
            alignment: const Alignment(-0.5, 0),
            child: SvgPicture.asset('assets/images/cat-paw.svg', width: 72),
          ),
          const SizedBox(height: DSDimens.size3xl),
          Text(
            "Let's set up\nyour cat's profile",
            textAlign: TextAlign.center,
            style: DSTextStyles.displayHero,
          ),
          const SizedBox(height: DSDimens.size3xl),
          // Lower-right paw (horizontally flipped)
          Align(
            alignment: const Alignment(0.5, 0),
            child: Transform.flip(
              flipX: true,
              child: SvgPicture.asset('assets/images/cat-paw.svg', width: 72),
            ),
          ),
          const Spacer(flex: 2),
          _QuoteCard(),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      decoration: BoxDecoration(
        color: ProfileIntroScreen._quoteSurface,
        borderRadius: BorderRadius.circular(DSRadii.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '2 min',
            style: DSTextStyles.displayLg.copyWith(fontSize: 22),
          ),
          const SizedBox(width: DSDimens.sizeS),
          Expanded(
            child: Text(
              'A quick profile unlocks tailored verdicts on every bag',
              style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
