import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/widgets/hatched_placeholder.dart';
import 'package:yucat/features/scan_history/presentation/bloc/scan_history_bloc.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_app_bar.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_state_view.dart';
import 'package:yucat/presentation/components/skeletons/product_list_skeleton.dart';
import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';
import 'package:yucat/features/litter_detail/presentation/widgets/litter_list_row.dart';

@RoutePage()
class ScanHistoryPage extends StatefulWidget {
  const ScanHistoryPage({super.key});

  @override
  State<ScanHistoryPage> createState() => _ScanHistoryPageState();
}

class _ScanHistoryPageState extends State<ScanHistoryPage> {
  late ScanHistoryBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<ScanHistoryBloc>();
    _bloc.add(const ScanHistoryInitialEvent());
  }

  Future<void> _openProduct(ProductDisplayModel product) async {
    await context.router.push(ProductDetailRoute(product: product));
    _bloc.add(const ScanHistoryRefreshEvent());
  }

  Future<void> _openLitter(LitterDisplayModel litter) async {
    await context.router.push(LitterDetailRoute(litter: litter));
    _bloc.add(const ScanHistoryRefreshEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.tintLavender,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DSAppBar.modal(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: BlocBuilder<ScanHistoryBloc, ScanHistoryState>(
                bloc: _bloc,
                buildWhen: (prev, curr) => prev != curr,
                builder: (context, state) => switch (state) {
                  ScanHistoryLoadingState() => const ProductListSkeleton(
                      padding: EdgeInsets.fromLTRB(
                        DSDimens.sizeL,
                        DSDimens.sizeS,
                        DSDimens.sizeL,
                        DSDimens.size4xl,
                      ),
                    ),
                  ScanHistoryLoadedState(:final products, :final litters) =>
                    state.isEmpty
                        ? _EmptyView()
                        : _LoadedList(
                            products: products,
                            litters: litters,
                            onTapProduct: _openProduct,
                            onTapLitter: _openLitter,
                          ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadedList extends StatelessWidget {
  final List<ProductDisplayModel> products;
  final List<LitterDisplayModel> litters;
  final ValueChanged<ProductDisplayModel> onTapProduct;
  final ValueChanged<LitterDisplayModel> onTapLitter;

  const _LoadedList({
    required this.products,
    required this.litters,
    required this.onTapProduct,
    required this.onTapLitter,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Both stores are capped at 50 entries, so a plain ListView is cheaper to
    // read than index arithmetic across two sections.
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        DSDimens.sizeL,
        DSDimens.sizeS,
        DSDimens.sizeL,
        DSDimens.size4xl,
      ),
      children: [
        // The page title always renders, so a history containing only litters
        // is still headed "Scan history" rather than "Litters". Per-category
        // subheads appear only when there is more than one category to tell
        // apart.
        _SectionHeader(
          title: l10n.scanHistoryTitle,
          subtitle: l10n.scanHistoryScanCount(products.length + litters.length),
        ),
        if (products.isNotEmpty) ...[
          if (litters.isNotEmpty)
            _SectionSubhead(
              title: l10n.foodSectionTitle,
              count: l10n.scanHistoryScanCount(products.length),
            ),
          for (final product in products) ...[
            _ScanHistoryRow(
              product: product,
              onTap: () => onTapProduct(product),
            ),
            const SizedBox(height: DSDimens.sizeS),
          ],
        ],
        if (litters.isNotEmpty) ...[
          if (products.isNotEmpty)
            _SectionSubhead(
              title: l10n.litterSectionTitle,
              count: l10n.litterSectionCount(litters.length),
            ),
          for (final litter in litters) ...[
            LitterListRow(
              litter: litter,
              onTap: () => onTapLitter(litter),
            ),
            const SizedBox(height: DSDimens.sizeS),
          ],
        ],
      ],
    );
  }
}

/// A per-category divider inside a two-category list. Rendered only when both
/// categories are present — with one category the page title already says what
/// the list is.
class _SectionSubhead extends StatelessWidget {
  final String title;
  final String count;

  const _SectionSubhead({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSDimens.sizeXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(title, style: DSTextStyles.titleMd),
          const SizedBox(width: DSDimens.sizeXxs),
          Text(
            count,
            style: DSTextStyles.caption.copyWith(color: DSColors.inkSecondary),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSDimens.sizeS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: DSTextStyles.displayLg),
          const SizedBox(height: DSDimens.sizeXxxs),
          Text(
            subtitle,
            style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkSecondary),
          ),
        ],
      ),
    );
  }
}

class _ScanHistoryRow extends StatelessWidget {
  final ProductDisplayModel product;
  final VoidCallback onTap;

  const _ScanHistoryRow({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasImage = product.imageUrl != null && product.imageUrl!.isNotEmpty;
    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSRadii.lg),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(DSRadii.md),
                      child: Container(
                        color: DSColors.tintLavender,
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const HatchedPlaceholder(),
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(DSRadii.md),
                      child: const HatchedPlaceholder(),
                    ),
            ),
            const SizedBox(width: DSDimens.sizeS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: DSTextStyles.titleMd,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.brand,
                    style: DSTextStyles.bodyMd.copyWith(
                      color: DSColors.inkSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: DSDimens.sizeS),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSDimens.sizeXs,
                vertical: DSDimens.sizeXxs,
              ),
              decoration: BoxDecoration(
                color: DSColors.tintSky,
                borderRadius: BorderRadius.circular(DSRadii.pill),
              ),
              child: Text(
                product.scoreDisplay,
                style: DSTextStyles.caption.copyWith(
                  color: DSColors.inkPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DSStateView.empty(
      mascotAsset: 'assets/images/cat-thinking.svg',
      tint: DSColors.tintCloud,
      headline: l10n.scanHistoryEmptyTitle,
      body: l10n.scanHistoryEmptyBody,
    );
  }
}
