import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/ds_quote_card.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

const _wsavaUrl =
    'https://wsava.org/global-guidelines/global-nutrition-guidelines/';

class DomainPitchScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const DomainPitchScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  Future<void> _openSource() async {
    final uri = Uri.parse(_wsavaUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      background: DSColors.tintCoral,
      onBack: onBack,
      footer: DSPillButton(label: 'Let\'s go', onPressed: onNext),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: DSDimens.sizeS),
          Text(
            "What's in\nthe bowl\nmatters",
            textAlign: TextAlign.center,
            style: DSTextStyles.displayLg,
          ),
          const SizedBox(height: DSDimens.sizeL),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeS),
            child: Text(
              'From kittenhood through senior years, food drives weight, coat, and longevity. The right diet is the biggest lever you have.',
              textAlign: TextAlign.center,
              style: DSTextStyles.bodyLg.copyWith(
                color: DSColors.inkSecondary,
              ),
            ),
          ),
          const Spacer(),
          DSQuoteCard(
            sourceTitle: 'WSAVA',
            body:
                'publishes Global Nutrition Guidelines that frame nutrition as a primary factor in feline health and longevity.',
            sourceLinkLabel: 'Read the guidelines',
            onSourceTap: _openSource,
          ),
          const SizedBox(height: DSDimens.sizeS),
        ],
      ),
    );
  }
}
