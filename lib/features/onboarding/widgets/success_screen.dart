import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

class SuccessScreen extends StatelessWidget {
  final VoidCallback onStart;

  /// At-a-glance chips describing the cat the user just created.
  final List<String> summary;

  const SuccessScreen({
    super.key,
    required this.onStart,
    this.summary = const [],
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      background: DSColors.tintMint,
      footer: DSPillButton(label: 'Start scanning', onPressed: onStart),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: DSColors.surfaceCard,
              shape: BoxShape.circle,
              boxShadow: DSShadows.e2,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: DSColors.accentSuccess,
              size: 56,
            ),
          ),
          const SizedBox(height: DSDimens.size3xl),
          Text(
            'You\'re all\nset!',
            textAlign: TextAlign.center,
            style: DSTextStyles.displayHero,
          ),
          const SizedBox(height: DSDimens.sizeS),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeS),
            child: Text(
              'Your cat\'s profile is ready. Time to find food that fits.',
              textAlign: TextAlign.center,
              style: DSTextStyles.bodyLg.copyWith(
                color: DSColors.inkSecondary,
              ),
            ),
          ),
          if (summary.isNotEmpty) ...[
            const SizedBox(height: DSDimens.sizeL),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: DSDimens.sizeXxs,
              runSpacing: DSDimens.sizeXxs,
              children: [
                for (final chip in summary) _SummaryChip(label: chip),
              ],
            ),
          ],
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;

  const _SummaryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeS,
        vertical: DSDimens.sizeXxs,
      ),
      decoration: BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.pill),
        boxShadow: DSShadows.e1,
      ),
      child: Text(
        label,
        style: DSTextStyles.label.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
