import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

class AddCatIntroScreen extends StatelessWidget {
  final VoidCallback onAddCat;
  final VoidCallback onBack;

  const AddCatIntroScreen({
    super.key,
    required this.onAddCat,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      background: DSColors.tintLavender,
      onBack: onBack,
      footer: DSPillButton(label: 'Add my cat', onPressed: onAddCat),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          SizedBox(
            height: 240,
            child: Image.asset(
              'assets/images/Illustrations/Add new cat.gif',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: DSDimens.size3xl),
          Text(
            'Let\'s get to\nknow your cat',
            textAlign: TextAlign.center,
            style: DSTextStyles.displayHero,
          ),
          const SizedBox(height: DSDimens.sizeS),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeS),
            child: Text(
              'A few quick questions so YuCat can match food to your cat\'s needs.',
              textAlign: TextAlign.center,
              style: DSTextStyles.bodyLg.copyWith(
                color: DSColors.inkSecondary,
              ),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
