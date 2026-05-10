import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/widgets/hatched_placeholder.dart';
import 'package:yucat/features/saved_products/presentation/bloc/saved_products_bloc.dart';
import 'package:yucat/presentation/components/ds_app_bar.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_state_view.dart';
import 'package:yucat/presentation/widgets/app_loading_widget.dart';

@RoutePage()
class SavedProductsPage extends StatefulWidget {
  const SavedProductsPage({super.key});

  @override
  State<SavedProductsPage> createState() => _SavedProductsPageState();
}

class _SavedProductsPageState extends State<SavedProductsPage> {
  late SavedProductsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<SavedProductsBloc>();
    _bloc.add(const SavedProductsInitialEvent());
  }

  Future<void> _openProduct(ProductDisplayModel product) async {
    await context.router.push(ProductDetailRoute(product: product));
    _bloc.add(const SavedProductsRefreshEvent());
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
              child: BlocBuilder<SavedProductsBloc, SavedProductsState>(
                bloc: _bloc,
                buildWhen: (prev, curr) => prev != curr,
                builder: (context, state) => switch (state) {
                  SavedProductsLoadingState() => const AppLoadingWidget(),
                  SavedProductsLoadedState(:final products) =>
                    products.isEmpty
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
          return Padding(
            padding: const EdgeInsets.only(bottom: DSDimens.sizeS),
            child: Text('Saved products', style: DSTextStyles.displayLg),
          );
        }
        final product = products[index - 1];
        return _SavedProductRow(
          product: product,
          onTap: () => onTapProduct(product),
        );
      },
    );
  }
}

class _SavedProductRow extends StatelessWidget {
  final ProductDisplayModel product;
  final VoidCallback onTap;

  const _SavedProductRow({required this.product, required this.onTap});

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
      illustrationAsset: 'assets/images/Illustrations/Add new cat.gif',
      headline: 'No saved products yet',
      body: 'Tap the bookmark on a product detail page to save it here.',
    );
  }
}
