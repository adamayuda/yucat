import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/cat_avatar.dart';

/// Horizontal row of cat photos that selects the active cat for the Home
/// screen: circular avatar with the name beneath, a ring on the selected one,
/// and a dashed "add" tile at the end. Lives inside `HomeGreetingCard`.
class HomeCatSelector extends StatelessWidget {
  final List<CatEntity> cats;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onAddCat;

  const HomeCatSelector({
    super.key,
    required this.cats,
    required this.selectedIndex,
    required this.onSelected,
    required this.onAddCat,
  });

  /// Diameter of the photo itself; the selection ring is drawn outside it.
  static const double avatarSize = 64;

  /// Gap between the photo and the ring drawn around it.
  static const double _ringInset = 3;

  static const double _ringWidth = 2.5;

  /// Fixed tile width so names of different lengths don't shift the row.
  static const double _tileWidth = 78;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // Trailing inset only: the card zeroes its right padding so tiles can
      // scroll all the way to its edge instead of stopping short of it.
      padding: const EdgeInsets.only(right: DSDimens.sizeL),
      child: Row(
        children: [
          for (var i = 0; i < cats.length; i++) ...[
            if (i > 0) const SizedBox(width: DSDimens.sizeM),
            _CatTile(
              cat: cats[i],
              selected: i == selectedIndex,
              onTap: () => onSelected(i),
            ),
          ],
          if (cats.isNotEmpty) const SizedBox(width: DSDimens.sizeM),
          _AddCatTile(onTap: onAddCat),
        ],
      ),
    );
  }
}

class _CatTile extends StatelessWidget {
  final CatEntity cat;
  final bool selected;
  final VoidCallback onTap;

  const _CatTile({
    required this.cat,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: cat.name,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: HomeCatSelector._tileWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(HomeCatSelector._ringInset),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    // Transparent rather than absent so both states measure the
                    // same — selecting a cat must not jog the row sideways.
                    color: selected
                        ? DSColors.accentInfo
                        : Colors.transparent,
                    width: HomeCatSelector._ringWidth,
                  ),
                ),
                child: CatAvatar(
                  photoUrl: cat.profileImageUrl,
                  size: HomeCatSelector.avatarSize,
                  background: DSColors.tintLavender,
                ),
              ),
              const SizedBox(height: DSDimens.sizeXxs),
              Text(
                cat.name,
                style: DSTextStyles.label.copyWith(
                  color: selected
                      ? DSColors.inkPrimary
                      : DSColors.inkSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCatTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddCatTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.homeAddCatShort,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: HomeCatSelector._tileWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Same total footprint as a ringed avatar so the tiles line up.
              Padding(
                padding: const EdgeInsets.all(
                  HomeCatSelector._ringInset + HomeCatSelector._ringWidth,
                ),
                child: CustomPaint(
                  painter: const _DashedCirclePainter(
                    color: DSColors.accentInfo,
                  ),
                  child: const SizedBox(
                    width: HomeCatSelector.avatarSize,
                    height: HomeCatSelector.avatarSize,
                    child: Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: DSColors.accentInfo,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: DSDimens.sizeXxs),
              Text(
                l10n.homeAddCatShort,
                style: DSTextStyles.label.copyWith(
                  color: DSColors.accentInfo,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dashed circular outline. Flutter's `Border` can't dash, so the circumference
/// is walked in fixed arc/gap steps instead.
class _DashedCirclePainter extends CustomPainter {
  final Color color;

  const _DashedCirclePainter({required this.color});

  static const double strokeWidth = 1.5;
  static const double dashLength = 6;
  static const double gapLength = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    if (radius <= 0) return;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final circumference = 2 * math.pi * radius;
    // Round the dash count so the pattern closes cleanly instead of leaving a
    // ragged overlap where the last dash meets the first.
    final steps = math.max(6, (circumference / (dashLength + gapLength)).round());
    final stepAngle = 2 * math.pi / steps;
    final dashAngle = stepAngle * dashLength / (dashLength + gapLength);

    for (var i = 0; i < steps; i++) {
      canvas.drawArc(rect, i * stepAngle, dashAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}
