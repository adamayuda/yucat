import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/health_carnet/presentation/models/health_due_item.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_labels.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// "Rabies · in 3 days" — the carnet's badge on a list row.
///
/// Renders **nothing** unless the item is overdue, urgent or due within a
/// month. A `later` item is real but not today's business, and a `toSchedule`
/// row is a gap rather than a deadline; badging either would make every cat
/// card carry a pill, and a pill on every card is no pill at all.
class HealthDuePill extends StatelessWidget {
  final HealthDueItem? item;
  final VoidCallback? onTap;

  const HealthDuePill({super.key, required this.item, this.onTap});

  static bool shows(HealthDueItem? item) =>
      item != null &&
      (item.urgency == HealthUrgency.overdue ||
          item.urgency == HealthUrgency.urgent ||
          item.urgency == HealthUrgency.soon);

  @override
  Widget build(BuildContext context) {
    final item = this.item;
    if (!shows(item)) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final colors = healthUrgencyColors(item!.urgency);
    final label =
        '${healthProtocolName(item.protocol.id, l10n)} · ${healthUrgencyLabel(item, l10n)}';

    final pill = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeXxs,
        vertical: DSDimens.sizeXxxs,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(DSRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            healthCategoryIcon(item.protocol.category),
            color: colors.ink,
            size: 14,
          ),
          const SizedBox(width: DSDimens.sizeXxxs),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DSTextStyles.caption.copyWith(
                color: colors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return pill;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: pill,
    );
  }
}
