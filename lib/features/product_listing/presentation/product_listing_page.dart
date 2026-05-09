import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_listing/presentation/bloc/product_listing_bloc.dart';
import 'package:yucat/features/search_products/presentation/widgets/product_row_card.dart';
import 'package:yucat/presentation/components/ds_app_bar.dart';
import 'package:yucat/presentation/widgets/app_loading_widget.dart';

@RoutePage()
class ProductListingPage extends StatefulWidget {
  final String brandName;

  const ProductListingPage({super.key, required this.brandName});

  @override
  State<ProductListingPage> createState() => _ProductListingPage();
}

class _ProductListingPage extends State<ProductListingPage> {
  late ProductListingBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<ProductListingBloc>();
    _bloc.add(ProductListingInitialEvent(brandName: widget.brandName));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.tintLavender,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DSAppBar.modal(
              title: widget.brandName,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: BlocBuilder<ProductListingBloc, ProductListingState>(
                bloc: _bloc,
                buildWhen: (previous, current) => previous != current,
                builder: (context, state) => switch (state) {
                  ProductListingLoadingState() => const AppLoadingWidget(),
                  ProductListingLoadedState(:final products) => _ProductList(
                      products: products,
                      onTap: (product) => _bloc.add(
                        NavigateToProductDetailEvent(
                          product: product,
                          context: context,
                        ),
                      ),
                    ),
                  _ => const SizedBox.shrink(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  final List<ProductDisplayModel> products;
  final void Function(ProductDisplayModel) onTap;

  const _ProductList({required this.products, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(DSDimens.sizeL),
          child: Text(
            'No products found for this brand.',
            textAlign: TextAlign.center,
            style: DSTextStyles.bodyMd,
          ),
        ),
      );
    }
    final bottomInset = MediaQuery.of(context).padding.bottom + DSDimens.sizeL;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        DSDimens.sizeL,
        DSDimens.sizeXxs,
        DSDimens.sizeL,
        bottomInset,
      ),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: DSDimens.sizeXs),
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductRowCard(
          product: product,
          onTap: () => onTap(product),
        );
      },
    );
  }
}
