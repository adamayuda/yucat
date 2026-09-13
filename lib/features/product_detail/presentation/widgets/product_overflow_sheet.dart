import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yucat/config/store_links.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/utils/verdict_headline.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/service_locator.dart';

/// The product's overflow menu: share the result, or report that something
/// about it is wrong. Both were a dead `more_horiz` button until now.
Future<void> showProductOverflowSheet(
  BuildContext context,
  ProductDisplayModel product,
) async {
  final l10n = AppLocalizations.of(context);
  final action = await _showSheet<_OverflowAction>(
    context,
    title: product.name,
    rows: (sheetContext) => [
      DSOptionRow(
        leadingIcon: Icons.ios_share_rounded,
        label: l10n.productDetailShare,
        onTap: () => Navigator.pop(sheetContext, _OverflowAction.share),
      ),
      DSOptionRow(
        leadingIcon: Icons.flag_outlined,
        label: l10n.productDetailReport,
        description: l10n.productDetailReportDescription,
        onTap: () => Navigator.pop(sheetContext, _OverflowAction.report),
      ),
    ],
  );
  if (action == null || !context.mounted) return;
  switch (action) {
    case _OverflowAction.share:
      await _share(context, product);
    case _OverflowAction.report:
      await _report(context, product);
  }
}

enum _OverflowAction { share, report }

/// What a scanner user can plausibly notice is wrong. Free text is
/// deliberately absent: a reason we can count beats a paragraph nobody reads.
enum ProductReportReason {
  wrongProduct('wrong_product'),
  wrongNutrition('wrong_nutrition'),
  wrongScore('wrong_score'),
  wrongImage('wrong_image'),
  other('other');

  final String wire;
  const ProductReportReason(this.wire);
}

Future<void> _share(BuildContext context, ProductDisplayModel product) async {
  final l10n = AppLocalizations.of(context);
  final text = product.dataUnavailable
      ? l10n.productDetailShareTextNoScore(
          product.name, product.brand, StoreLinks.current)
      : l10n.productDetailShareText(
          product.name,
          product.brand,
          product.score,
          verdictHeadlineFor(product.ratingText, l10n),
          StoreLinks.current,
        );
  sl<LogEventUsecase>().call(
    eventName: AnalyticsEvents.productShared,
    properties: {
      ..._props(product),
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
  await SharePlus.instance.share(ShareParams(text: text));
}

Future<void> _report(BuildContext context, ProductDisplayModel product) async {
  final l10n = AppLocalizations.of(context);
  String label(ProductReportReason r) => switch (r) {
        ProductReportReason.wrongProduct => l10n.productDetailReportWrongProduct,
        ProductReportReason.wrongNutrition =>
          l10n.productDetailReportWrongNutrition,
        ProductReportReason.wrongScore => l10n.productDetailReportWrongScore,
        ProductReportReason.wrongImage => l10n.productDetailReportWrongImage,
        ProductReportReason.other => l10n.productDetailReportOther,
      };
  final reason = await _showSheet<ProductReportReason>(
    context,
    title: l10n.productDetailReportTitle,
    rows: (sheetContext) => [
      for (final r in ProductReportReason.values)
        DSOptionRow(
          label: label(r),
          onTap: () => Navigator.pop(sheetContext, r),
        ),
    ],
  );
  if (reason == null) return;
  sl<LogEventUsecase>().call(
    eventName: AnalyticsEvents.productReported,
    properties: {
      ..._props(product),
      'reason': reason.wire,
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.productDetailReportThanks)),
  );
}

Map<String, Object?> _props(ProductDisplayModel p) => {
      'product_name': p.name,
      'product_brand': p.brand,
      'product_score': p.score,
      'data_unavailable': p.dataUnavailable,
      'has_product_key': p.cacheKey != null,
      'product_key': p.cacheKey,
      'food_type': p.foodType,
    };

Future<T?> _showSheet<T>(
  BuildContext context, {
  required String title,
  required List<Widget> Function(BuildContext sheetContext) rows,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      decoration: const BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DSRadii.xl)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            DSDimens.sizeL,
            DSDimens.sizeS,
            DSDimens.sizeL,
            DSDimens.sizeL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DSColors.surfaceCardDim,
                    borderRadius: BorderRadius.circular(DSRadii.pill),
                  ),
                ),
              ),
              const SizedBox(height: DSDimens.sizeL),
              Text(
                title,
                style: DSTextStyles.titleMd,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: DSDimens.sizeS),
              ...[
                for (final (i, row) in rows(sheetContext).indexed) ...[
                  if (i > 0) const SizedBox(height: DSDimens.sizeXs),
                  row,
                ],
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
