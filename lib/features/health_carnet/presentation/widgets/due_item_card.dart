import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/health_carnet/presentation/models/health_due_item.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_date_format.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_labels.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

/// One line of the "À venir" list.
///
/// Only an **overdue** item gets the red outline. A `toSchedule` item — a
/// protocol with no record at all, whose date is derived from an approximated
/// birth date — is styled neutrally on purpose: it is a gap in the carnet, not
/// evidence the cat missed anything.
class DueItemCard extends StatelessWidget {
  final HealthDueItem item;
  final VoidCallback onMarkDone;
  final VoidCallback onSnooze;
  final bool busy;

  const DueItemCard({
    super.key,
    required this.item,
    required this.onMarkDone,
    required this.onSnooze,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = healthLocaleOf(context);
    final category = item.protocol.category;
    final isOverdue = item.urgency == HealthUrgency.overdue;
    final dateLine = _dateLine(l10n, locale);

    final card = DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: healthCategoryTint(category),
                  borderRadius: BorderRadius.circular(DSRadii.md),
                ),
                child: Icon(
                  healthCategoryIcon(category),
                  size: 22,
                  color: healthCategoryInk(category),
                ),
              ),
              const SizedBox(width: DSDimens.sizeXs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: DSDimens.sizeXxs,
                      runSpacing: DSDimens.sizeXxxs,
                      children: [
                        Text(
                          healthProtocolName(item.protocol.id, l10n),
                          style: DSTextStyles.titleMd,
                        ),
                        _UrgencyPill(item: item),
                      ],
                    ),
                    if (dateLine.isNotEmpty) ...[
                      const SizedBox(height: DSDimens.sizeXxxs),
                      Text(dateLine, style: DSTextStyles.bodyMd),
                    ],
                    const SizedBox(height: DSDimens.sizeXxxs),
                    Text(
                      healthDueSubtitle(item, l10n, locale),
                      style: DSTextStyles.bodyMd.copyWith(
                        color: DSColors.inkTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DSDimens.sizeXs),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DSPillButton(
                  label: l10n.healthCarnetMarkDone,
                  onPressed: busy ? null : onMarkDone,
                  showChevron: false,
                  verticalPadding: DSDimens.sizeXs,
                ),
              ),
              const SizedBox(width: DSDimens.sizeXxs),
              Expanded(
                flex: 2,
                child: DSPillButton(
                  label: l10n.healthCarnetSnooze,
                  onPressed: busy ? null : onSnooze,
                  variant: DSPillButtonVariant.secondary,
                  showChevron: false,
                  verticalPadding: DSDimens.sizeXs,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (!isOverdue) return card;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DSRadii.xl),
        border: Border.all(color: DSColors.accentDanger, width: 1.5),
      ),
      child: card,
    );
  }

  /// Empty for a `toSchedule` item.
  ///
  /// Those are all dated today by construction, so a date line would just
  /// restate the "To schedule" pill — and printing a specific day would lend
  /// false precision to a date derived from an approximated birth date. The
  /// subtitle already says there is no record yet.
  String _dateLine(AppLocalizations l10n, String locale) {
    final due = item.dueDate;
    final days = item.daysUntil;
    if (due == null || days == null) return '';
    if (item.urgency == HealthUrgency.toSchedule) return '';
    return l10n.healthCarnetDueBy(healthFormatDueDate(due, days, locale));
  }
}

class _UrgencyPill extends StatelessWidget {
  final HealthDueItem item;

  const _UrgencyPill({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = healthUrgencyColors(item.urgency);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeXxs,
        vertical: DSDimens.sizeXxxs,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(DSRadii.pill),
      ),
      child: Text(
        healthUrgencyLabel(item, l10n),
        style: DSTextStyles.label.copyWith(
          color: colors.ink,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
