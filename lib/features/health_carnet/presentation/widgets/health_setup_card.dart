import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

/// The standing invitation at the top of the Upcoming tab while the carnet has
/// no history. The setup sheet opens by itself on first visit; this is how it
/// stays reachable after that sheet was dismissed, so a "later" never becomes
/// a "never".
class HealthSetupCard extends StatelessWidget {
  final VoidCallback onStart;

  const HealthSetupCard({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DSCard(
      background: DSColors.tintSky,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.healthSetupCardTitle, style: DSTextStyles.titleMd),
          const SizedBox(height: DSDimens.sizeXxs),
          Text(l10n.healthSetupCardBody, style: DSTextStyles.bodyMd),
          const SizedBox(height: DSDimens.sizeS),
          DSPillButton(
            label: l10n.healthSetupCardCta,
            onPressed: onStart,
            verticalPadding: DSDimens.sizeXs,
          ),
        ],
      ),
    );
  }
}
