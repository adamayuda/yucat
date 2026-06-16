import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// A blurred, locked preview of the cat's recommended foods — the conversion
/// carrot. Shows how many better foods we found for the cat, with the list
/// itself blurred under a "Subscribe to unlock" overlay. Revealed in-app after
/// the user subscribes.
class LockedPicksTeaser extends StatelessWidget {
  final String catName;
  final int count;

  const LockedPicksTeaser({
    super.key,
    required this.catName,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = count.clamp(1, 3);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSDimens.sizeS),
      decoration: BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.lg),
        boxShadow: DSShadows.e1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 18, color: DSColors.accentSuccess),
              const SizedBox(width: DSDimens.sizeXxs),
              Expanded(
                child: Text(
                  l10n.brandTeaserFound(count, catName),
                  style: DSTextStyles.titleMd,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSDimens.sizeS),
          ClipRRect(
            borderRadius: BorderRadius.circular(DSRadii.md),
            child: Stack(
              children: [
                // Blurred placeholder rows.
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                  child: Column(
                    children: [
                      for (var i = 0; i < rows; i++) ...[
                        if (i > 0) const SizedBox(height: DSDimens.sizeS),
                        const _GhostRow(),
                      ],
                    ],
                  ),
                ),
                // Lock overlay.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: DSColors.surfaceCard.withValues(alpha: 0.35),
                    ),
                    child: const Center(
                      child: Icon(Icons.lock_rounded,
                          color: DSColors.inkPrimary, size: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DSDimens.sizeS),
          Text(
            l10n.brandTeaserLockedHint,
            style: DSTextStyles.caption.copyWith(color: DSColors.inkSecondary),
          ),
        ],
      ),
    );
  }
}

/// A blurred stand-in for a product row (thumb + two text bars).
class _GhostRow extends StatelessWidget {
  const _GhostRow();

  @override
  Widget build(BuildContext context) {
    Widget bar(double w, double h) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: DSColors.surfaceCardDim,
            borderRadius: BorderRadius.circular(DSRadii.sm),
          ),
        );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: DSColors.tintLavender,
            borderRadius: BorderRadius.circular(DSRadii.md),
          ),
        ),
        const SizedBox(width: DSDimens.sizeS),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: DSDimens.sizeXxs),
            bar(180, 12),
            const SizedBox(height: DSDimens.sizeXs),
            bar(110, 10),
            const SizedBox(height: DSDimens.sizeXs),
            bar(70, 18),
          ],
        ),
      ],
    );
  }
}
