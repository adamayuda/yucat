import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/ds_stat_pill.dart';
import 'package:yucat/presentation/components/line_chart_card.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

// TODO(open #4): replace placeholder copy with a real, sourced stat
// once data is available. See design/design.md §12.

class SocialProofScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const SocialProofScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

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
          const SizedBox(height: DSDimens.size3xl),
          const LineChartCard(),
          const SizedBox(height: DSDimens.sizeL),
          DSStatPill(
            stat: '2×',
            description: 'Cat parents who use YuCat report happier mealtimes',
            background: DSColors.surfaceCard,
            icon: Icons.trending_up_rounded,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
