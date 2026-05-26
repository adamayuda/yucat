import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/ds_stat_pill.dart';
import 'package:yucat/presentation/components/line_chart_card.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

class ProofChartScreen extends StatelessWidget {
  final VoidCallback onNext;

  const ProofChartScreen({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      background: DSColors.tintMint,
      footer: DSPillButton(label: 'Next', onPressed: onNext),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: DSDimens.sizeS),
          Text(
            'Find the right\nfood faster',
            style: DSTextStyles.displayLg,
          ),
          const SizedBox(height: DSDimens.sizeS),
          Text(
            'Scan by scan, YuCat homes in on what fits your cat — instead of guessing brand to brand.',
            style: DSTextStyles.bodyLg.copyWith(color: DSColors.inkSecondary),
          ),
          const SizedBox(height: DSDimens.size3xl),
          const LineChartCard(
            yourLabel: 'With YuCat',
            theirsLabel: 'Guessing',
            yourTagText: 'YuCat',
            xAxisLabel: 'Bags scanned',
          ),
          const SizedBox(height: DSDimens.sizeL),
          // TODO: replace placeholder stat with a real, cited figure.
          DSStatPill(
            stat: '76%',
            description: 'of cats are on a better-fit food within 2 weeks',
            background: DSColors.surfaceCard,
            icon: Icons.trending_up_rounded,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
