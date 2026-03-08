import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_listing/presentation/bloc/product_listing_bloc.dart';
import 'package:yucat/presentation/top_app_bar/top_app_bar.dart';
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
  void dispose() {
    // Don't close the bloc here - it's provided at the app level
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductListingBloc, ProductListingState>(
      bloc: _bloc,
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) => _onStateChangeBuilder(state),
    );
  }

  Widget _onStateChangeBuilder(ProductListingState state) {
    switch (state) {
      case ProductListingLoadingState():
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: TopAppBar(
              title: widget.brandName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          body: const AppLoadingWidget(),
        );
      case ProductListingLoadedState():
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: TopAppBar(
              title: widget.brandName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          body: Column(
            children: [
              if (state.products.isNotEmpty) ...[
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: DSDimens.sizeS),
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      return _ProductCard(
                        product: state.products[index],
                        onTap: () {
                          _bloc.add(
                            NavigateToProductDetailEvent(
                              product: state.products[index],
                              context: context,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );

      default:
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: TopAppBar(
              title: widget.brandName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          body: const SizedBox.shrink(),
        );
    }
  }
}

class _ProductCard extends StatelessWidget {
  final ProductDisplayModel product;
  final VoidCallback? onTap;

  const _ProductCard({required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DSDimens.sizeS),
      child: Container(
        margin: EdgeInsets.only(bottom: DSDimens.sizeXxs),
        decoration: BoxDecoration(
          color: DSColors.white,
          borderRadius: BorderRadius.circular(DSDimens.sizeS),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: EdgeInsets.all(DSDimens.sizeXxs),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSDimens.sizeS),
          ),
          splashColor: DSColors.lightGrey.withOpacity(0.3),
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: DSColors.lightGrey,
              borderRadius: BorderRadius.circular(DSDimens.sizeS),
            ),
            child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(DSDimens.sizeS),
                    child: Image.network(product.imageUrl!, fit: BoxFit.cover),
                  )
                : Icon(Icons.image, color: DSColors.darkGrey),
          ),
          title: Text(
            product.name,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: DSDimens.sizeXxxs),
              Text(
                product.brand,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: DSColors.darkGrey),
              ),
              SizedBox(height: DSDimens.sizeXxxs),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: product.ratingColor.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: DSDimens.sizeXs),
                  Text(
                    '${product.scoreDisplay} ${product.ratingText}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: DSColors.black),
                  ),
                ],
              ),
            ],
          ),
          trailing: Icon(Icons.chevron_right, color: DSColors.darkGrey),
        ),
      ),
    );
  }
}
