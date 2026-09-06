import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/health_carnet/presentation/models/health_due_item.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_date_format.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_labels.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';

/// The recurring treatments a cat is on right now — monthly antiparasitics,
/// quarterly deworming — with the next date for each.
///
/// A **regrouping of `dueItems`**, not a second data source. It exists because a
/// short-cycle treatment reads differently from a one-off appointment: the
/// question is "am I keeping this up", not "have I booked it".
class OngoingTreatmentsCard extends StatelessWidget {
  final List<HealthDueItem> treatments;

  const OngoingTreatmentsCard({super.key, required this.treatments});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = healthLocaleOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.healthCarnetOngoingTitle, style: DSTextStyles.titleMd),
        const SizedBox(height: DSDimens.sizeXxs),
        DSCard(
          padding: const EdgeInsets.symmetric(
            horizontal: DSDimens.sizeS,
            vertical: DSDimens.sizeXxs,
          ),
          child: Column(
            children: [
              for (var i = 0; i < treatments.length; i++) ...[
                if (i > 0)
                  const Divider(height: 1, color: DSColors.tintGreySoft),
                _Row(item: treatments[i], locale: locale),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final HealthDueItem item;
  final String locale;

  const _Row({required this.item, required this.locale});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final category = item.protocol.category;
    final due = item.dueDate;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSDimens.sizeXs),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: healthCategoryTint(category),
              borderRadius: BorderRadius.circular(DSRadii.sm),
            ),
            child: Icon(
              healthCategoryIcon(category),
              size: 18,
              color: healthCategoryInk(category),
            ),
          ),
          const SizedBox(width: DSDimens.sizeXs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  healthProtocolName(item.protocol.id, l10n),
                  style: DSTextStyles.bodyLg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  healthRecurrenceLabel(item.intervalDays, l10n),
                  style: DSTextStyles.bodyMd,
                ),
              ],
            ),
          ),
          if (due != null)
            Text(
              l10n.healthCarnetOngoingNext(
                healthFormatDueDate(due, item.daysUntil ?? 0, locale),
              ),
              style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkTertiary),
            ),
        ],
      ),
    );
  }
}
