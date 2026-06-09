import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class DSBottomNavItem {
  final IconData icon;
  final String label;

  const DSBottomNavItem({required this.icon, required this.label});
}

/// Vertical space a tab page's scrollable content should reserve at the bottom
/// so its last item clears the floating bottom nav (which overlays content).
/// Add to `MediaQuery.padding.bottom`.
const double kFloatingNavClearance = 96;

/// Floating pill bottom navigation.
///
/// Renders centered above the safe-area edge with a `surfaceCardDim`
/// pill background, `DSShadows.e1` lift, and monochrome rounded icons.
/// The active tab gets a soft `accentSuccessSoft` chip behind its icon.
class DSBottomNav extends StatelessWidget {
  final List<DSBottomNavItem> items;
  final int activeIndex;
  final ValueChanged<int> onTap;

  const DSBottomNav({
    super.key,
    required this.items,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DSDimens.sizeL,
          DSDimens.sizeXxs,
          DSDimens.sizeL,
          DSDimens.sizeXxs,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(
                horizontal: DSDimens.sizeXxs,
              ),
              decoration: BoxDecoration(
                color: DSColors.surfaceCardDim,
                borderRadius: BorderRadius.circular(DSRadii.pill),
                boxShadow: DSShadows.e1,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < items.length; i++)
                    _DSBottomNavTab(
                      item: items[i],
                      selected: i == activeIndex,
                      onTap: () => onTap(i),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DSBottomNavTab extends StatelessWidget {
  final DSBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _DSBottomNavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: item.label,
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(DSRadii.pill),
        onTap: onTap,
        child: SizedBox(
          width: 72,
          height: 56,
          child: Center(
            child: AnimatedContainer(
              duration: DSMotion.durFast,
              curve: DSMotion.curveStandard,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? DSColors.accentSuccessSoft
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(DSRadii.pill),
              ),
              child: Icon(
                item.icon,
                size: 24,
                color: selected
                    ? DSColors.inkPrimary
                    : DSColors.inkTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
