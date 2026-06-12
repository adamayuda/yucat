import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// Compact greeting at the top of Home. Uses the wizard's cat mascot icon
/// (not the cat's photo — that lives on the selector chip + snapshot card).
class HomeHeader extends StatelessWidget {
  final CatEntity? activeCat;

  const HomeHeader({super.key, this.activeCat});

  static const double _iconSize = 48;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cat = activeCat;
    final subtitle = cat != null
        ? l10n.homeReadyForCat(cat.name)
        : l10n.homeReadyToScan;

    return Row(
      children: [
        Container(
          width: _iconSize,
          height: _iconSize,
          decoration: const BoxDecoration(
            color: DSColors.tintLavender,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: ClipOval(
            child: SvgPicture.asset(
              'assets/images/cat-icon-profile.svg',
              width: _iconSize,
              height: _iconSize,
              fit: BoxFit.cover,
            ),
          ),
        ),
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
