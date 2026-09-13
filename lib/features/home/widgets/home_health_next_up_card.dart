import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/health_carnet/presentation/models/health_next_up.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_date_format.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_labels.dart';
import 'package:yucat/features/health_carnet/presentation/widgets/due_item_card.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/cat_avatar.dart';
import 'package:yucat/presentation/components/ds_card.dart';

/// Home's "Next up" card: the one carnet item that matters most right now,
/// across every cat — or, for a cat with no records, the way into the setup —
/// or, for a household whose carnets are all set up and quiet, an all-clear
/// that names the next act beyond the horizon.
///
/// This is the carnet's surface on the screen every user sees; Cat Detail
/// reaches roughly one active subscriber in four. The card is absent only when
/// [nextUp] is null (no cats, or every read failed). The all-clear keeps the
/// same avatar / eyebrow / title / subtitle geometry as the other two, so the
/// skeleton's `_NextUpBone` fits all three.
class HomeHealthNextUpCard extends StatelessWidget {
  final HealthNextUp nextUp;
  final VoidCallback onTap;

  const HomeHealthNextUpCard({
    super.key,
    required this.nextUp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = healthLocaleOf(context);
    final cat = nextUp.cat;

    final (String title, String subtitle, Widget? pill) = switch (nextUp) {
      HealthNextUpDue(:final item) => (
          healthProtocolName(item.protocol.id, l10n),
          healthDueSubtitle(item, l10n, locale),
          HealthUrgencyPill(item: item),
        ),
      HealthNextUpSetup() => (
          l10n.healthSetupTitle(cat.name),
          l10n.healthSetupCardBody,
          null,
        ),
      HealthNextUpAllClear(:final nextItem) => (
          l10n.homeHealthAllClearTitle,
          nextItem == null || nextItem.dueDate == null
              ? l10n.homeHealthAllClearNone
              : l10n.homeHealthAllClearNext(
                  healthProtocolName(nextItem.protocol.id, l10n),
                  healthFormatMonthYear(nextItem.dueDate!, locale),
                ),
          null,
        ),
    };
    final othersDue = switch (nextUp) {
      HealthNextUpDue(:final othersDueCount) => othersDueCount,
      _ => 0,
    };

    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      onTap: onTap,
      child: Row(
        children: [
          CatAvatar(photoUrl: cat.profileImageUrl, size: 44),
          const SizedBox(width: DSDimens.sizeXs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeHealthEyebrow(cat.name),
                  style: DSTextStyles.label.copyWith(
                    color: DSColors.inkTertiary,
                  ),
                ),
                const SizedBox(height: DSDimens.sizeXxxs),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: DSDimens.sizeXxs,
                  runSpacing: DSDimens.sizeXxxs,
                  children: [
                    Text(title, style: DSTextStyles.titleMd),
                    if (pill != null) pill,
                  ],
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: DSDimens.sizeXxxs),
                  Text(
                    subtitle,
                    style: DSTextStyles.bodyMd.copyWith(
                      color: DSColors.inkSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (othersDue > 0) ...[
                  const SizedBox(height: DSDimens.sizeXxxs),
                  Text(
                    l10n.homeHealthOthersDue(othersDue),
                    style: DSTextStyles.caption.copyWith(
                      color: DSColors.accentInfo,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: DSDimens.sizeXxs),
          const Icon(
            Icons.chevron_right,
            color: DSColors.inkTertiary,
          ),
        ],
      ),
    );
  }
}
