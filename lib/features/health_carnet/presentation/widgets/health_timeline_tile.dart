import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_date_format.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_labels.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';

/// One past act, on the left-hand rail.
///
/// Swipe from the trailing edge to delete. ⚠️ `confirmDismiss` deliberately
/// returns **false** even when the user confirms: it dispatches the delete and
/// lets the bloc's next state drop the row. Letting `Dismissible` remove the
/// widget itself would animate the row away before the write is known to have
/// succeeded, and a failed delete would then have to animate it back.
/// Rail geometry. The dot sits [_dotTop] down so it lines up with the category
/// pill on the card's first line rather than with the card's top edge.
const double _railWidth = DSDimens.sizeL;
const double _railCentre = 5.0;
const double _dotSize = 10.0;
const double _dotTop = DSDimens.sizeS;

class HealthTimelineTile extends StatelessWidget {
  final HealthEventEntity event;

  /// True for the last tile, which stops the rail rather than running it into
  /// the padding below.
  final bool isLast;

  final Future<void> Function() onConfirmDelete;

  const HealthTimelineTile({
    super.key,
    required this.event,
    required this.isLast,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = healthLocaleOf(context);
    final ink = healthCategoryInk(event.category);

    // A protocol-backed record stores no title — it is rendered from its
    // `protocolId` so it stays correct in whatever language the app is in now.
    final title = event.title.isNotEmpty
        ? event.title
        : healthProtocolName(event.protocolId ?? '', l10n);

    final attribution = [
      if (event.vetName != null) event.vetName!,
      if (event.clinic != null) event.clinic!,
    ].join(' · ');

    // Laid out as a Stack rather than an IntrinsicHeight row: the connector has
    // to span the card's full height, and the obvious way to write that —
    // `IntrinsicHeight` around a `Row` whose rail column holds an `Expanded`
    // divider — asks a flex child for an intrinsic dimension, which is both
    // costly per row and the classic source of "RenderBox was not laid out".
    // A positioned line takes its height from the Stack instead, and the Stack
    // sizes to the card.
    final row = Stack(
      children: [
        if (!isLast)
          Positioned(
            left: _railCentre,
            top: _dotTop,
            bottom: 0,
            child: Container(width: 1.2, color: DSColors.tintGreySoft),
          ),
        Positioned(
          left: _railCentre - _dotSize / 2,
          top: _dotTop,
          child: Container(
            width: _dotSize,
            height: _dotSize,
            decoration: BoxDecoration(color: ink, shape: BoxShape.circle),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: _railWidth,
            bottom: DSDimens.sizeS,
          ),
          child: DSCard(
            padding: const EdgeInsets.all(DSDimens.sizeS),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _CategoryPill(event: event),
                    const SizedBox(width: DSDimens.sizeXxs),
                    Expanded(
                      child: Text(
                        event.performedAt == null
                            ? ''
                            : healthFormatDate(event.performedAt!, locale),
                        style: DSTextStyles.bodyMd,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DSDimens.sizeXxs),
                Text(title, style: DSTextStyles.titleMd),
                if (event.notes != null) ...[
                  const SizedBox(height: DSDimens.sizeXxxs),
                  Text(event.notes!, style: DSTextStyles.bodyMd),
                ],
                if (event.weightKg != null) ...[
                  const SizedBox(height: DSDimens.sizeXxxs),
                  Row(
                    children: [
                      const Icon(
                        Icons.monitor_weight_outlined,
                        size: 15,
                        color: DSColors.inkTertiary,
                      ),
                      const SizedBox(width: DSDimens.sizeXxxs),
                      Text(
                        '${healthFormatKg(event.weightKg!, locale)} kg',
                        style: DSTextStyles.bodyMd.copyWith(
                          color: DSColors.inkTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
                if (attribution.isNotEmpty) ...[
                  const SizedBox(height: DSDimens.sizeXxs),
                  Text(
                    attribution,
                    style: DSTextStyles.bodyMd.copyWith(
                      color: DSColors.inkTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );

    // A record with no id was never persisted and cannot be deleted.
    if (event.id == null) return row;

    return Dismissible(
      key: ValueKey(event.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await onConfirmDelete();
        return false;
      },
      background: Padding(
        padding: const EdgeInsets.only(
          left: _railWidth,
          bottom: DSDimens.sizeS,
        ),
        child: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: DSDimens.sizeL),
          decoration: BoxDecoration(
            color: DSColors.accentDanger,
            borderRadius: BorderRadius.circular(DSRadii.xl),
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: DSColors.inkInverse,
          ),
        ),
      ),
      child: row,
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final HealthEventEntity event;

  const _CategoryPill({required this.event});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeXxs,
        vertical: DSDimens.sizeXxxs,
      ),
      decoration: BoxDecoration(
        color: healthCategoryTint(event.category),
        borderRadius: BorderRadius.circular(DSRadii.pill),
      ),
      child: Text(
        healthCategoryLabel(event.category, l10n),
        style: DSTextStyles.label.copyWith(
          color: healthCategoryInk(event.category),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
