import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';

class AddCatCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddCatCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DSCard(
      onTap: onTap,
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: DSColors.tintMint,
              borderRadius: BorderRadius.circular(DSRadii.pill),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.add_rounded,
              color: DSColors.accentSuccess,
              size: 28,
            ),
          ),
          const SizedBox(width: DSDimens.sizeS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.catListingAddAnotherCat, style: DSTextStyles.titleMd),
                const SizedBox(height: DSDimens.sizeXxxs),
                Text(
                  l10n.catListingCreateNewProfile,
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
