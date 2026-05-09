import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_card.dart';

class ScanCounterCard extends StatelessWidget {
  final int? scansRemaining;
  final int? maxFreeScans;
  final bool isPremium;
  final VoidCallback? onUpgradeTap;

  const ScanCounterCard({
    super.key,
    required this.scansRemaining,
    required this.maxFreeScans,
    required this.isPremium,
    this.onUpgradeTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isPremium) {
      return DSCard(
        child: Row(
          children: [
            const Icon(
              Icons.workspace_premium_rounded,
              color: DSColors.accentSuccess,
              size: 28,
            ),
            const SizedBox(width: DSDimens.sizeS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Unlimited scans', style: DSTextStyles.titleMd),
                  const SizedBox(height: DSDimens.sizeXxxs),
                  Text(
                    'You\'re on YuCat Pro.',
                    style: DSTextStyles.bodyMd.copyWith(
                      color: DSColors.inkSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final remaining = scansRemaining ?? 0;
    final max = maxFreeScans ?? 3;
    final progress = max == 0 ? 0.0 : (max - remaining) / max;

    return DSCard(
      onTap: onUpgradeTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Free scans left',
                  style: DSTextStyles.titleMd,
                ),
              ),
              Text(
                '$remaining of $max',
                style: DSTextStyles.titleMd.copyWith(
                  color: remaining == 0
                      ? DSColors.accentDanger
                      : DSColors.inkPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSDimens.sizeS),
          ClipRRect(
            borderRadius: BorderRadius.circular(DSRadii.pill),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(color: DSColors.surfaceCardDim),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0, 1),
                    child: Container(
                      color: remaining == 0
                          ? DSColors.accentDanger
                          : DSColors.accentSuccess,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: DSDimens.sizeS),
          Row(
            children: [
              Text(
                'Subscribe for unlimited',
                style: DSTextStyles.bodyMd.copyWith(
                  color: DSColors.inkSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: DSDimens.sizeXxxs),
              const Icon(
                Icons.chevron_right_rounded,
                color: DSColors.inkSecondary,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
