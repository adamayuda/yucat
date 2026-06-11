import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

/// Shows the "guiding, not prescribing" medical disclaimer as a modal
/// bottom sheet. Surfaced once the user starts sharing health data, right
/// before the breed step. Resolves when the sheet is dismissed.
Future<void> showMedicalDisclaimerSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => const _MedicalDisclaimerSheet(),
  );
}

class _MedicalDisclaimerSheet extends StatelessWidget {
  const _MedicalDisclaimerSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DSRadii.xl)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            DSDimens.sizeL,
            DSDimens.sizeS,
            DSDimens.sizeL,
            DSDimens.sizeL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DSColors.surfaceCardDim,
                    borderRadius: BorderRadius.circular(DSRadii.pill),
                  ),
                ),
              ),
              const SizedBox(height: DSDimens.sizeL),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: DSColors.tintCoral,
                  borderRadius: BorderRadius.circular(DSRadii.md),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: DSColors.accentDanger,
                  size: 28,
                ),
              ),
              const SizedBox(height: DSDimens.sizeS),
              Text(
                l10n.disclaimerTitle,
                style: DSTextStyles.headlineMd,
              ),
              const SizedBox(height: DSDimens.sizeXs),
              Text(
                l10n.disclaimerBody1,
                style: DSTextStyles.bodyMd.copyWith(
                  color: DSColors.inkSecondary,
                ),
              ),
              const SizedBox(height: DSDimens.sizeXs),
              Text(
                l10n.disclaimerBody2,
                style: DSTextStyles.bodyMd.copyWith(
                  color: DSColors.inkSecondary,
                ),
              ),
              const SizedBox(height: DSDimens.sizeL),
              Center(
                child: DSPillButton(
                  label: l10n.commonGotIt,
                  showChevron: false,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
