import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/product_detail/presentation/mappers/product_entity_to_model_mapper.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/search_products/presentation/bloc/search_bloc.dart';
import 'package:yucat/features/search_products/presentation/widgets/search_discover_loaded_page.dart';
import 'package:yucat/features/search_products/presentation/widgets/search_discover_loading_page.dart';
import 'package:yucat/service_locator.dart';
import 'package:yucat/presentation/top_app_bar/top_app_bar.dart';

@RoutePage()
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPage();
}

class _SearchPage extends State<SearchPage> {
  late SearchBloc _bloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = context.read<SearchBloc>();
    _bloc.add(SearchInitialEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
    _bloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchBloc, SearchState>(
      bloc: _bloc,
      listenWhen: (previous, current) =>
          current is SearchNavigateToProductDetailState,
      listener: (context, state) {
        if (state is SearchNavigateToProductDetailState) {
          // Convert ProductEntity to ProductModel with all nutritional data
          final productEntityToModelMapper = sl<ProductEntityToModelMapper>();
          final productDetailModel = productEntityToModelMapper(
            state.productEntity,
          );
          context.router.push(ProductDetailRoute(product: productDetailModel));
        }
      },
      child: BlocBuilder<SearchBloc, SearchState>(
        bloc: _bloc,
        buildWhen: (previous, current) =>
            previous != current &&
            current is! SearchNavigateToProductDetailState,
        builder: (context, state) => _onStateChangeBuilder(state),
      ),
    );
  }

  Widget _onStateChangeBuilder(SearchState state) {
    switch (state) {
      case SearchDiscoverLoadingState():
        return const SearchDiscoverLoadingPage();
      case SearchDiscoverLoadedState(:final brands):
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: TopAppBar(
              title: 'Search',
              hideBackButton: true,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: DSDimens.sizeS,
                  right: DSDimens.sizeS,
                  bottom: DSDimens.sizeS,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a cat food',
                    filled: true,
                    fillColor: Colors.grey[200],
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    _bloc.add(SearchQueryEvent(query: value));
                  },
                ),
              ),
              SearchDiscoverLoadedPage(brands: brands),
            ],
          ),
        );
      case SearchLoadingState():
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: TopAppBar(
              title: 'Search',
              hideBackButton: true,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          body: Center(child: Text('Loading')),
        );
      case SearchLoadedState():
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: TopAppBar(
              title: 'Search',
              hideBackButton: true,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: DSDimens.sizeS,
                  right: DSDimens.sizeS,
                  bottom: DSDimens.sizeS,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a cat food',
                    filled: true,
                    fillColor: Colors.grey[200],
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    _bloc.add(SearchQueryEvent(query: value));
                  },
                ),
              ),
              if (state.isLoading)
                Expanded(child: Center(child: CircularProgressIndicator()))
              else if (state.products.isNotEmpty) ...[
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
      case SearchHiddenState():
        // Show search bar even in hidden state
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: TopAppBar(title: '', hideBackButton: true),
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(DSDimens.sizeS),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a cat food',
                    filled: true,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    _bloc.add(SearchQueryEvent(query: value));
                  },
                ),
              ),
            ],
          ),
        );
      case SearchErrorState():
        return Scaffold(
          // appBar: PreferredSize(
          //   preferredSize: Size.fromHeight(kToolbarHeight),
          //   child: TopAppBar(title: 'Search', hideBackButton: true),
          // ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(DSDimens.sizeS),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a cat food',
                    filled: true,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    _bloc.add(SearchQueryEvent(query: value));
                  },
                ),
              ),
              Expanded(
                child: Center(child: Text('Error occurred. Please try again.')),
              ),
            ],
          ),
        );
      default:
        // Default case - show search bar
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: TopAppBar(title: '', hideBackButton: true),
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(DSDimens.sizeS),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a cat food',
                    filled: true,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    _bloc.add(SearchQueryEvent(query: value));
                  },
                ),
              ),
            ],
          ),
        );
    }
  }

  // void _dispatch(SearchEvent event) => _bloc.add(event);
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
