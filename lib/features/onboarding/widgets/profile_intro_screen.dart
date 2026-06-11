import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/onboarding_floating_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

class ProfileIntroScreen extends StatelessWidget {
  final VoidCallback onNext;

  static const Color _background = DSColors.tintCloud;
  static const Color _quoteSurface = Color(0xFFE5E4EB);

  const ProfileIntroScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OnboardingScaffold(
      background: _background,
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
            l10n.onboardingProfileIntroTitle,
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
          // Center so the stretch crossAxisAlignment doesn't force the pill to
          // full width.
          Center(
            child: OnboardingFloatingButton(label: l10n.commonNext, onPressed: onNext),
          ),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      decoration: BoxDecoration(
        color: ProfileIntroScreen._quoteSurface,
        borderRadius: BorderRadius.circular(DSRadii.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(l10n.onboardingProfileIntroTime, style: DSTextStyles.displayLg.copyWith(fontSize: 22)),
          const SizedBox(width: DSDimens.sizeS),
          Expanded(
            child: Text(
              l10n.onboardingProfileIntroQuote,
              style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
