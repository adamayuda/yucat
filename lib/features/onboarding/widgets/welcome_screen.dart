import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onRestorePurchases;

  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
    required this.onRestorePurchases,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFDDE9F6), Color(0xFFF7E9EE)],
      ),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DSPillButton(label: 'Get started', onPressed: onGetStarted),
          const SizedBox(height: DSDimens.sizeXxs),
          DSTextLink(
            label: 'I already have an account',
            onPressed: onRestorePurchases,
          ),
          const SizedBox(height: DSDimens.sizeXxs),
          Text(
            "By continuing you're accepting our\nTerms of Use and Privacy Notice",
            textAlign: TextAlign.center,
            style: DSTextStyles.caption,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 1),
          Center(
            child: Lottie.asset(
              'assets/images/Illustrations/lottie.json',
              height: 260,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: DSDimens.sizeM),
          Text(
            'Decode\nevery\ncat food\nlabel',
            style: DSTextStyles.displayHero.copyWith(
              fontSize: 64,
              height: 0.95,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
