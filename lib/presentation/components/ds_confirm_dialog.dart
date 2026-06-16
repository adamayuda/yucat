import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

/// Shows an on-brand centered confirmation dialog and resolves to `true`
/// (confirmed), `false` (cancelled), or `null` (dismissed by tapping outside).
///
/// Design-system styled: white [DSColors.surfaceCard] card, a tinted icon badge,
/// Bricolage title, body line, and a stacked CTA — a [DSPillButton] (red
/// `danger` variant when [destructive]) above a quiet [DSTextLink] cancel.
/// Mirrors the modal vocabulary of `medical_disclaimer_sheet.dart`.
Future<bool?> showDSConfirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = true,
  IconData icon = Icons.delete_outline_rounded,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => _DSConfirmDialog(
      title: title,
      body: body,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
      icon: icon,
    ),
  );
}

class _DSConfirmDialog extends StatelessWidget {
  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;
  final IconData icon;

  const _DSConfirmDialog({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.destructive,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: DSColors.surfaceCard,
      insetPadding: const EdgeInsets.symmetric(horizontal: DSDimens.size3xl),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DSRadii.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DSDimens.sizeL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color:
                    destructive ? DSColors.tintCoral : DSColors.tintLavender,
                borderRadius: BorderRadius.circular(DSRadii.md),
              ),
              child: Icon(
                icon,
                color:
                    destructive ? DSColors.accentDanger : DSColors.inkPrimary,
                size: 28,
              ),
            ),
            const SizedBox(height: DSDimens.sizeS),
            Text(
              title,
              textAlign: TextAlign.center,
              style: DSTextStyles.headlineMd,
            ),
            const SizedBox(height: DSDimens.sizeXs),
            Text(
              body,
              textAlign: TextAlign.center,
              style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkSecondary),
            ),
            const SizedBox(height: DSDimens.sizeL),
            DSPillButton(
              label: confirmLabel,
              variant: destructive
                  ? DSPillButtonVariant.danger
                  : DSPillButtonVariant.primary,
              showChevron: false,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: DSDimens.sizeXxs),
            DSTextLink(
              label: cancelLabel,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}
