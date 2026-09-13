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
/// across every cat — or, for a cat with no records, the way into the setup.
///
/// This is the carnet's only surface on the screen every user sees; Cat Detail
/// (the other entry point) reaches roughly one active subscriber in four. The
/// card renders nothing when [nextUp] is null, like the content lanes do on an
/// empty or failed read — a well-kept carnet earns a quiet Home.
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
