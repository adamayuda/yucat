import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/ds_stat_pill.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

const _apopUrl = 'https://www.petobesityprevention.org/';

class SocialProofScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const SocialProofScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  Future<void> _openSource() async {
    final uri = Uri.parse(_apopUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      background: DSColors.tintMint,
      onBack: onBack,
      footer: DSPillButton(label: 'Next', onPressed: onNext),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: DSDimens.sizeS),
          Text(
            'Better food,\nbetter cats',
            textAlign: TextAlign.left,
            style: DSTextStyles.displayLg,
          ),
          const SizedBox(height: DSDimens.sizeS),
          Text(
            'Diet shapes weight, energy, and long-term health. YuCat helps you spot the differences before they reach the bowl.',
            style: DSTextStyles.bodyLg.copyWith(color: DSColors.inkSecondary),
          ),
          const SizedBox(height: DSDimens.size3xl),
          DSStatPill(
            stat: '61%',
            description: 'of US cats are overweight or obese',
            background: DSColors.surfaceCard,
            icon: Icons.monitor_weight_rounded,
          ),
          const SizedBox(height: DSDimens.sizeXxs),
          GestureDetector(
            onTap: _openSource,
            child: Text(
              'Source: APOP — 2022 Pet Obesity Prevalence Survey',
              style: DSTextStyles.caption.copyWith(
                color: DSColors.inkSecondary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
