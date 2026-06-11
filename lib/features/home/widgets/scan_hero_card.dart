import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';

class ScanHeroCard extends StatelessWidget {
  final VoidCallback onTap;

  const ScanHeroCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DSCard(
      onTap: onTap,
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: DSColors.inkPrimary,
              borderRadius: BorderRadius.circular(DSRadii.lg),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: DSColors.inkInverse,
              size: 32,
            ),
          ),
          const SizedBox(width: DSDimens.sizeS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.homeScanProduct, style: DSTextStyles.headlineMd),
                const SizedBox(height: DSDimens.sizeXxxs),
                Text(
                  l10n.homeScanProductSubtitle,
                  style: DSTextStyles.bodyMd.copyWith(
                    color: DSColors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: DSColors.inkTertiary,
            size: 24,
          ),
        ],
      ),
    );
  }
}
