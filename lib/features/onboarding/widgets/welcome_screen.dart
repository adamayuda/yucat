import 'package:flutter/material.dart';
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
      background: DSColors.tintSky,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DSPillButton(label: 'Get started', onPressed: onGetStarted),
          const SizedBox(height: DSDimens.sizeXxs),
          DSTextLink(
            label: 'Restore purchases',
            onPressed: onRestorePurchases,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          SizedBox(
            height: 220,
            child: Image.asset(
              'assets/images/Illustrations/Hey, welcome!.gif',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: DSDimens.size3xl),
          Text(
            'Find food\nthat fits\nyour cat',
            textAlign: TextAlign.center,
            style: DSTextStyles.displayHero,
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
