import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_haptics.dart';

/// Equal-width single-select segments inside a pill track.
///
/// The app had no segmented control of any kind — `SegmentedButton`,
/// `ToggleButtons` and `TabBar` appear nowhere, because tab navigation goes
/// through `AutoTabsRouter` + `DSBottomNav` instead. This fills that gap for
/// *in-page* switching.
///
/// The selected/unselected token pair is taken verbatim from
/// `ArticleCategoryStrip._CategoryChip` so the two read as one system. The
/// difference is layout, and it is deliberate: a category strip scrolls
/// horizontally and can hold any number of chips, whereas a segmented control
/// shows a small fixed set at equal width and must never scroll — if a caller
/// needs more than about four segments, it wants the strip instead.
class DSSegmentedControl extends StatelessWidget {
  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const DSSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSDimens.sizeXxxs),
      decoration: BoxDecoration(
        color: DSColors.tintMist,
        borderRadius: BorderRadius.circular(DSRadii.pill),
      ),
      child: Row(
        children: [
          for (var i = 0; i < segments.length; i++)
            Expanded(
              child: _Segment(
                label: segments[i],
                selected: i == selectedIndex,
                onTap: () {
                  if (i == selectedIndex) return;
                  DSHaptics.selection();
                  onSelected(i);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: DSMotion.durFast,
          curve: DSMotion.curveStandard,
          padding: const EdgeInsets.symmetric(vertical: DSDimens.sizeXs),
          decoration: BoxDecoration(
            color: selected ? DSColors.surfaceCard : Colors.transparent,
            borderRadius: BorderRadius.circular(DSRadii.pill),
            boxShadow: selected ? DSShadows.e1 : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DSTextStyles.bodyLg.copyWith(
              color: selected ? DSColors.inkPrimary : DSColors.inkSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
