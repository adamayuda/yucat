import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/widgets/hatched_placeholder.dart';
import 'package:yucat/features/scan_history/presentation/bloc/scan_history_bloc.dart';
import 'package:yucat/presentation/components/ds_app_bar.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_state_view.dart';
import 'package:yucat/presentation/widgets/app_loading_widget.dart';

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
                  ScanHistoryLoadingState() => const AppLoadingWidget(),
                  ScanHistoryLoadedState(:final products) => products.isEmpty
                      ? _EmptyView()
                      : _LoadedList(
                          products: products,
                          onTapProduct: _openProduct,
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
  final ValueChanged<ProductDisplayModel> onTapProduct;

  const _LoadedList({
    required this.products,
    required this.onTapProduct,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        DSDimens.sizeL,
        DSDimens.sizeS,
        DSDimens.sizeL,
        DSDimens.size4xl,
      ),
      itemCount: products.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: DSDimens.sizeS),
      itemBuilder: (context, index) {
        if (index == 0) {
          final n = products.length;
          return Padding(
            padding: const EdgeInsets.only(bottom: DSDimens.sizeS),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Scan history', style: DSTextStyles.displayLg),
                const SizedBox(height: DSDimens.sizeXxxs),
                Text(
                  '$n scan${n == 1 ? '' : 's'}',
                  style: DSTextStyles.bodyMd.copyWith(
                    color: DSColors.inkSecondary,
                  ),
                ),
              ],
            ),
          );
        }
        final product = products[index - 1];
        return _ScanHistoryRow(
          product: product,
          onTap: () => onTapProduct(product),
        );
      },
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
    return const DSStateView.empty(
      illustrationAsset: 'assets/images/Illustrations/empty-state.gif',
      headline: 'No scans yet',
      body: 'Foods you scan will show up here.',
    );
  }
}
