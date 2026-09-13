import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/health_carnet/presentation/models/cat_health_summary.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';

/// "Whose record?" — for a surface that speaks for the whole household
/// (Profile's Health row) but must open *one* cat's carnet.
///
/// Each row carries the cat's own state, so the owner picks with the reason
/// in view: "2 due soon", "All up to date", or "Not set up yet". Returns the
/// chosen cat, or null when dismissed.
Future<CatEntity?> showHealthCatPickerSheet(
  BuildContext context, {
  required List<CatHealthSummary> summaries,
}) {
  return showModalBottomSheet<CatEntity>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _HealthCatPickerSheet(summaries: summaries),
  );
}

class _HealthCatPickerSheet extends StatelessWidget {
  final List<CatHealthSummary> summaries;

  const _HealthCatPickerSheet({required this.summaries});

  String _description(CatHealthSummary summary, AppLocalizations l10n) {
    if (!summary.hasHistory) return l10n.catDetailHealthSetup;
    final due = summary.dueSoonCount;
    if (due > 0) return l10n.profileHealthCount(due);
    return l10n.catDetailHealthAllClear;
  }

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
              Text(l10n.healthCatPickerTitle, style: DSTextStyles.titleMd),
              const SizedBox(height: DSDimens.sizeS),
              for (final summary in summaries) ...[
                DSOptionRow(
                  label: summary.cat.name,
                  description: _description(summary, l10n),
                  leadingIcon: Icons.pets_rounded,
                  onTap: () => Navigator.of(context).pop(summary.cat),
                ),
                const SizedBox(height: DSDimens.sizeXxs),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
