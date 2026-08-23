import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class DSBottomNavItem {
  final IconData icon;
  final String label;

  const DSBottomNavItem({required this.icon, required this.label});
}

/// Vertical space a tab page's scrollable content should reserve at the bottom
/// so its last item clears the bottom nav (which overlays content).
/// Add to `MediaQuery.padding.bottom`.
const double kFloatingNavClearance = 76;

/// Height of the nav's icon+label row, above the safe-area inset.
const double _kNavContentHeight = 56;

/// Full-width frosted bottom navigation.
///
/// Spans edge to edge and runs to the very bottom of the screen — the
/// home-indicator inset is padding *inside* the bar, so the blur and tint
/// continue behind the indicator. A `BackdropFilter` frosts whatever scrolls
/// underneath; a hairline top border separates it from the page.
///
/// Each slot is an outlined icon above its label, tinted [DSColors.accentInfo]
/// when selected and [DSColors.inkTertiary] otherwise.
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
    // ClipRect is mandatory: an unclipped BackdropFilter blurs the whole screen.
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: DSColors.surfaceCard.withValues(alpha: 0.72),
            border: Border(
              top: BorderSide(
                color: DSColors.inkPrimary.withValues(alpha: 0.06),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: _kNavContentHeight,
              // The bar height is fixed, so cap text scaling rather than let a
              // large accessibility size overflow it.
              child: MediaQuery.withClampedTextScaling(
                maxScaleFactor: 1.2,
                child: Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Expanded(
                        child: _DSBottomNavTab(
                          item: items[i],
                          selected: i == activeIndex,
                          onTap: () => onTap(i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
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
      child: GestureDetector(
        // No InkWell: the nearest Material ancestor sits *below* the frosted
        // layer, so a ripple would paint underneath it and never be seen.
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: selected ? 1 : 0, end: selected ? 1 : 0),
          duration: DSMotion.durFast,
          curve: DSMotion.curveStandard,
          builder: (context, t, _) {
            final tint = Color.lerp(
              DSColors.inkTertiary,
              DSColors.accentInfo,
              t,
            )!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 24, color: tint),
                const SizedBox(height: DSDimens.sizeXxxs),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSDimens.sizeXxxs,
                  ),
                  child: Text(
                    item.label,
                    style: DSTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: tint,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
