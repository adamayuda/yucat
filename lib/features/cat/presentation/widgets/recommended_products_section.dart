import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/presentation/utils/cat_product_recommendations.dart';
import 'package:yucat/features/cat/presentation/widgets/product_picks_list.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// Self-fetching "Top picks for {name}" section for home + cat detail. Loads the
/// per-cat recommendations, shows a light skeleton while loading, and hides
/// itself entirely when there are none. Re-fetches when the cat changes.
class RecommendedProductsSection extends StatefulWidget {
  final CatEntity cat;
  final int limit;

  const RecommendedProductsSection({
    super.key,
    required this.cat,
    this.limit = 5,
  });

  @override
  State<RecommendedProductsSection> createState() =>
      _RecommendedProductsSectionState();
}

class _RecommendedProductsSectionState
    extends State<RecommendedProductsSection> {
  bool _loading = true;
  List<ProductPick> _picks = const [];
  String? _loadedSignature;

  /// Reload key: the cat id plus every attribute the scorer reads. Keying on id
  /// alone would skip a refetch after an in-place edit (same id, new fields),
  /// leaving stale picks on screen even though the cache was invalidated.
  static String _signature(CatEntity cat) => [
        cat.id,
        cat.age,
        cat.ageGroup,
        cat.weightCategory,
        cat.activityLevel,
        cat.neuteredStatus,
        cat.breed,
        (cat.healthConditions ?? const []).toList()..sort(),
      ].join('|');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sig = _signature(widget.cat);
    if (_loadedSignature != sig) {
      _loadedSignature = sig;
      _load();
    }
  }

  @override
  void didUpdateWidget(covariant RecommendedProductsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final sig = _signature(widget.cat);
    if (_loadedSignature != sig) {
      _loadedSignature = sig;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final l10n = AppLocalizations.of(context);
    final picks =
        await recommendProductsForCat(widget.cat, l10n, limit: widget.limit);
    if (!mounted || _signature(widget.cat) != _loadedSignature) return;
    setState(() {
      _picks = picks;
      _loading = false;
    });
  }

  void _openProduct(ProductPick pick) {
    context.router.push(ProductDetailRoute(product: pick.product));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_loading) {
      return _SkeletonPicks(title: l10n.productPicksTitle(widget.cat.name));
    }
    return ProductPicksList(
      title: l10n.productPicksTitle(widget.cat.name),
      picks: _picks,
      onTap: _openProduct,
    );
  }
}

/// Lightweight placeholder shown while picks load.
class _SkeletonPicks extends StatelessWidget {
  final String title;

  const _SkeletonPicks({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: DSTextStyles.titleMd),
        const SizedBox(height: DSDimens.sizeS),
        for (var i = 0; i < 2; i++) ...[
          if (i > 0) const SizedBox(height: DSDimens.sizeS),
          Container(
            height: 96,
            decoration: BoxDecoration(
              color: DSColors.surfaceCardDim,
              borderRadius: BorderRadius.circular(DSRadii.lg),
            ),
          ),
        ],
      ],
    );
  }
}
