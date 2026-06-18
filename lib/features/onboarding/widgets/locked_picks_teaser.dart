import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/presentation/utils/cat_product_recommendations.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// A partially-locked preview of the cat's recommended foods — the conversion
/// carrot. We reveal a real fit-score badge and one benefit per pick (the value
/// signal), but keep the product's identity (name + image) obscured by a blur.
/// Fully revealed in-app after the user subscribes.
///
/// When [picks] is empty (offline / recommendation failure) it falls back to a
/// generic blurred ghost-row layout so the section never looks broken.
class LockedPicksTeaser extends StatelessWidget {
  final String catName;
  final List<ProductPick> picks;

  /// Used only for the header count when [picks] is empty (fallback path).
  final int fallbackCount;

  const LockedPicksTeaser({
    super.key,
    required this.catName,
    required this.picks,
    this.fallbackCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasPicks = picks.isNotEmpty;
    final shown = hasPicks ? picks.take(3).toList() : const <ProductPick>[];
    final count = hasPicks ? shown.length : fallbackCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: DSColors.accentSuccess,
            ),
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
        if (hasPicks)
          for (var i = 0; i < shown.length; i++) ...[
            if (i > 0) const SizedBox(height: DSDimens.sizeS),
            _PickRow(pick: shown[i]),
          ]
        else
          _GhostPicks(rows: count.clamp(1, 3)),
      ],
    );
  }
}

/// One recommendation: the whole row (real image, name, score, benefit) is
/// rendered but kept under a soft blur, so its identity stays teasingly hidden
/// until the user subscribes.
class _PickRow extends StatelessWidget {
  final ProductPick pick;

  const _PickRow({required this.pick});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _scoreColors(pick.product.ratingColor);
    final benefit =
        pick.why ??
        (pick.product.pros.isNotEmpty ? pick.product.pros.first : null);

    return ClipRect(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductThumb(imageUrl: pick.product.imageUrl),
            const SizedBox(width: DSDimens.sizeS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pick.product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DSTextStyles.titleMd,
                        ),
                      ),
                      const SizedBox(width: DSDimens.sizeXs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DSDimens.sizeXs,
                          vertical: DSDimens.sizeXxxs,
                        ),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(DSRadii.pill),
                        ),
                        child: Text(
                          '${pick.product.score}/100',
                          style: DSTextStyles.caption.copyWith(
                            color: fg,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (benefit != null) ...[
                    const SizedBox(height: DSDimens.sizeXs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 1),
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 15,
                            color: DSColors.accentSuccess,
                          ),
                        ),
                        const SizedBox(width: DSDimens.sizeXxs),
                        Expanded(
                          child: Text(
                            benefit,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: DSTextStyles.bodyMd.copyWith(
                              color: DSColors.inkPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

(Color, Color) _scoreColors(ProductRatingColor rating) {
  return switch (rating) {
    ProductRatingColor.green => (
      DSColors.accentSuccessSoft,
      DSColors.accentSuccess,
    ),
    ProductRatingColor.yellow => (
      const Color(0xFFFFF3D6),
      const Color(0xFFB37800),
    ),
    ProductRatingColor.red => (DSColors.coralSurface, DSColors.accentDanger),
  };
}

/// The real product thumbnail. Identity is hidden by the soft blur applied to
/// the whole row by [_PickRow] (and [_GhostRow]), so this just renders the
/// image — falling back to a lavender tile when there's no image.
class _ProductThumb extends StatelessWidget {
  final String? imageUrl;

  const _ProductThumb({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(DSRadii.md),
      child: SizedBox(
        width: 56,
        height: 56,
        child: hasImage
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _LavenderTile(),
              )
            : const _LavenderTile(),
      ),
    );
  }
}

/// Plain lavender fill used behind the blur when no product image is available.
class _LavenderTile extends StatelessWidget {
  const _LavenderTile();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: DSColors.tintLavender),
      child: SizedBox.expand(),
    );
  }
}

/// Fallback when no real picks loaded — still one lock per product row so the
/// "locked picks" intent reads clearly even offline.
class _GhostPicks extends StatelessWidget {
  final int rows;

  const _GhostPicks({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < rows; i++) ...[
          if (i > 0) const SizedBox(height: DSDimens.sizeS),
          const _GhostRow(),
        ],
      ],
    );
  }
}

/// A stand-in product row: lavender thumb + text bars under the same soft blur.
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
    return ClipRect(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ProductThumb(),
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
        ),
      ),
    );
  }
}
