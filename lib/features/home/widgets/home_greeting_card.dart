import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/home/widgets/home_cat_selector.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';

/// Top card of the Home dashboard: greeting over the cat picker. It is the
/// only place the active cat is chosen — the sections below read the selection
/// rather than offering their own.
class HomeGreetingCard extends StatelessWidget {
  final List<CatEntity> cats;
  final int selectedIndex;
  final ValueChanged<int> onCatSelected;
  final VoidCallback onAddCat;

  const HomeGreetingCard({
    super.key,
    required this.cats,
    required this.selectedIndex,
    required this.onCatSelected,
    required this.onAddCat,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final greeting =
        cats.isNotEmpty ? l10n.homeGreetingHey : l10n.homeGreetingWelcome;

    return DSCard(
      // Right padding is zero on purpose: the selector carries its own trailing
      // inset so tiles scroll to the card's edge instead of stopping short.
      padding: const EdgeInsets.fromLTRB(
        DSDimens.sizeL,
        DSDimens.sizeL,
        0,
        DSDimens.sizeL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: DSDimens.sizeL),
            child: Row(
              children: [
                const _MascotIcon(),
                const SizedBox(width: DSDimens.sizeS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting 👋',
                        style: DSTextStyles.displayLg,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
            ),
          ),
          const SizedBox(height: DSDimens.sizeM),
          HomeCatSelector(
            cats: cats,
            selectedIndex: selectedIndex,
            onSelected: onCatSelected,
            onAddCat: onAddCat,
          ),
        ],
      ),
    );
  }
}

/// The wizard's cat mascot, beside the greeting. Not the user's cat photo —
/// those live in the picker row directly below.
class _MascotIcon extends StatelessWidget {
  const _MascotIcon();

  static const double _size = 48;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: const BoxDecoration(
        color: DSColors.tintLavender,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: ClipOval(
        child: SvgPicture.asset(
          'assets/images/cat-icon-profile.svg',
          width: _size,
          height: _size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
