import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/cat_avatar.dart';

/// Compact greeting at the top of Home. Shows the active cat's avatar and a
/// personalized prompt, or generic copy when the user has no cats.
class HomeHeader extends StatelessWidget {
  final CatEntity? activeCat;

  const HomeHeader({super.key, this.activeCat});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cat = activeCat;
    final subtitle = cat != null
        ? l10n.homeReadyForCat(cat.name)
        : l10n.homeReadyToScan;

    return Row(
      children: [
        CatAvatar(photoUrl: cat?.profileImageUrl, size: 48),
        const SizedBox(width: DSDimens.sizeS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cat != null ? l10n.homeGreetingHey : l10n.homeGreetingWelcome,
                style: DSTextStyles.headlineMd,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: DSTextStyles.bodyMd.copyWith(
                  color: DSColors.inkSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
