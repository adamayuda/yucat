import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/presentation/utils/cat_product_recommendations.dart';
import 'package:yucat/features/cat/presentation/widgets/product_picks_list.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/utils/cat_product_assessment.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/service_locator.dart';

/// "Better for {cat}" — up to three catalogue foods that out-fit the product on
/// screen for the selected cat, rendered under the verdict card.
///
/// This is the loop a scanner app lives on: scan → verdict → *something better*
/// → scan again. Without it a mediocre verdict is a dead end, which is what
/// the data showed — subscribers scanned on day 0 and 93 % never scanned again
/// in week one.
///
/// Renders nothing while loading and nothing when there is no better food —
/// a great product should simply end at its verdict, not at an empty heading.
/// Keyed by the parent on the selected cat so a cat switch starts a fresh load.
///
/// Analytics are emitted here, not in a bloc: `ProductDetailBloc` knows
/// nothing about cats, and this widget is the only place that knows whether
/// the list actually rendered.
class BetterAlternativesSection extends StatefulWidget {
  final CatEntity cat;
  final ProductDisplayModel product;

  const BetterAlternativesSection({
    super.key,
    required this.cat,
    required this.product,
  });

  @override
  State<BetterAlternativesSection> createState() =>
      _BetterAlternativesSectionState();
}

class _BetterAlternativesSectionState extends State<BetterAlternativesSection> {
  List<ProductPick> _picks = const [];
  bool _loaded = false;
  bool _logged = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  Future<void> _load() async {
    final l10n = AppLocalizations.of(context);
    final picks = await betterAlternativesFor(widget.cat, widget.product, l10n);
    if (!mounted) return;
    setState(() => _picks = picks);
    if (picks.isNotEmpty && !_logged) {
      _logged = true;
      sl<LogEventUsecase>().call(
        eventName: AnalyticsEvents.alternativesShown,
        properties: {
          ..._productProps(l10n),
          'count': picks.length,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  Map<String, Object?> _productProps(AppLocalizations l10n) => {
        'product_name': widget.product.name,
        'product_brand': widget.product.brand,
        'product_score': widget.product.score,
        'current_fit':
            evaluateCatProduct(widget.cat, widget.product, l10n).score,
        'cat_age_group': widget.cat.ageGroup,
        'cat_has_health_conditions':
            (widget.cat.healthConditions ?? const []).isNotEmpty,
      };

  void _open(ProductPick pick) {
    final l10n = AppLocalizations.of(context);
    sl<LogEventUsecase>().call(
      eventName: AnalyticsEvents.alternativeTapped,
      properties: {
        ..._productProps(l10n),
        'alternative_name': pick.product.name,
        'alternative_brand': pick.product.brand,
        'alternative_score': pick.product.score,
        'alternative_fit': pick.fit,
        'position': _picks.indexOf(pick),
        'source': 'product_detail',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    context.router.push(ProductDetailRoute(product: pick.product));
  }

  @override
  Widget build(BuildContext context) {
    if (_picks.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: DSDimens.sizeL),
      child: ProductPicksList(
        title: l10n.productDetailBetterForCat(widget.cat.name),
        picks: _picks,
        onTap: _open,
      ),
    );
  }
}

