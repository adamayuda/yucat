import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// Compact greeting at the top of Home. Uses the wizard's cat mascot icon
/// (not the cat's photo — that lives on the My cats section's chips + card).
/// The subtitle is intentionally generic — cat context lives in the My cats
/// section, not here.
class HomeHeader extends StatelessWidget {
  /// Whether the user has at least one cat — only switches the greeting wording.
  final bool hasCats;

  const HomeHeader({super.key, this.hasCats = false});

  static const double _iconSize = 48;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
                hasCats ? l10n.homeGreetingHey : l10n.homeGreetingWelcome,
                style: DSTextStyles.headlineMd,
              ),
              const SizedBox(height: 2),
              Text(
                l10n.homeReadyToScan,
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
