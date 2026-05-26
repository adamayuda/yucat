import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
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
                'Guiding, not prescribing',
                style: DSTextStyles.headlineMd,
              ),
              const SizedBox(height: DSDimens.sizeXs),
              Text(
                'YuCat suggests foods based on your cat\'s profile and the ingredients we read off each product. It is not a substitute for veterinary advice.',
                style: DSTextStyles.bodyMd.copyWith(
                  color: DSColors.inkSecondary,
                ),
              ),
              const SizedBox(height: DSDimens.sizeXs),
              Text(
                'For diagnosed conditions or sudden changes in weight, appetite, or behavior, please consult a licensed veterinarian.',
                style: DSTextStyles.bodyMd.copyWith(
                  color: DSColors.inkSecondary,
                ),
              ),
              const SizedBox(height: DSDimens.sizeL),
              Center(
                child: DSPillButton(
                  label: 'Got it',
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
