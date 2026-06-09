import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/product_detail/presentation/mappers/product_entity_to_model_mapper.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/search_products/presentation/bloc/search_bloc.dart';
import 'package:yucat/features/search_products/presentation/widgets/product_row_card.dart';
import 'package:yucat/features/search_products/presentation/widgets/search_discover_skeleton.dart';
import 'package:yucat/features/search_products/presentation/widgets/search_discover_view.dart';
import 'package:yucat/features/search_products/presentation/widgets/search_text_field.dart';
import 'package:yucat/presentation/components/ds_app_bar.dart';
import 'package:yucat/presentation/components/ds_state_view.dart';
import 'package:yucat/presentation/components/skeletons/product_list_skeleton.dart';
import 'package:yucat/service_locator.dart';

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

  void _onQueryChanged(String value) {
    _bloc.add(SearchQueryEvent(query: value));
  }

  void _onClear() {
    _searchController.clear();
    _bloc.add(const SearchQueryEvent(query: ''));
  }

  void _onSubmitted(String query) {
    _bloc.add(SubmitSearchEvent(query: query));
  }

  void _onRecentTap(String query) {
    _searchController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    _bloc.add(RecentSearchSelectedEvent(query: query));
  }

  void _onClearRecents() {
    _bloc.add(const ClearRecentSearchesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchBloc, SearchState>(
      bloc: _bloc,
      listenWhen: (previous, current) =>
          current is SearchNavigateToProductDetailState,
      listener: (context, state) {
        if (state is SearchNavigateToProductDetailState) {
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
        builder: (context, state) => _buildScaffold(state),
      ),
    );
  }

  Widget _buildScaffold(SearchState state) {
    return Scaffold(
      backgroundColor: DSColors.tintLavender,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DSAppBar.tab(title: 'Search'),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DSDimens.sizeL,
                0,
                DSDimens.sizeL,
                DSDimens.sizeS,
              ),
              child: SearchTextField(
                controller: _searchController,
                onChanged: _onQueryChanged,
                onClear: _onClear,
                onSubmitted: _onSubmitted,
              ),
            ),
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(SearchState state) {
    return switch (state) {
      SearchDiscoverLoadingState() => const SearchDiscoverSkeleton(),
      SearchDiscoverLoadedState(:final brands, :final recentSearches) =>
        SearchDiscoverView(
          brands: brands,
          recentSearches: recentSearches,
          onRecentTap: _onRecentTap,
          onClearRecents: _onClearRecents,
        ),
      SearchLoadingState() => const ProductListSkeleton(
          padding: EdgeInsets.fromLTRB(
            DSDimens.sizeL,
            DSDimens.sizeXxs,
            DSDimens.sizeL,
            DSDimens.size4xl,
          ),
        ),
      SearchLoadedState(:final isLoading, :final products) => _ResultsList(
          isLoading: isLoading,
          products: products,
          onTap: (product) => _bloc.add(
            NavigateToProductDetailEvent(product: product, context: context),
          ),
        ),
      SearchErrorState() => _SearchError(
          onRetry: () => _bloc.add(SearchInitialEvent()),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _ResultsList extends StatelessWidget {
  final bool isLoading;
  final List<ProductDisplayModel> products;
  final void Function(ProductDisplayModel) onTap;

  const _ResultsList({
    required this.isLoading,
    required this.products,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const ProductListSkeleton(
        padding: EdgeInsets.fromLTRB(
          DSDimens.sizeL,
          DSDimens.sizeXxs,
          DSDimens.sizeL,
          DSDimens.size4xl,
        ),
      );
    }
    if (products.isEmpty) {
      return const DSStateView.empty(
        illustrationAsset: 'assets/images/Illustrations/empty-state.gif',
        headline: 'No matches',
        body: 'Try a different name, or browse popular brands.',
      );
    }
    final n = products.length;
    final caption = '$n result${n == 1 ? '' : 's'}';
    final bottomInset = MediaQuery.of(context).padding.bottom + 96;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        DSDimens.sizeL,
        DSDimens.sizeXxs,
        DSDimens.sizeL,
        bottomInset,
      ),
      itemCount: products.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: DSDimens.sizeXs),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: DSDimens.sizeXxs),
            child: Text(
              caption,
              style: DSTextStyles.caption.copyWith(
                color: DSColors.inkSecondary,
              ),
            ),
          );
        }
        final product = products[index - 1];
        return ProductRowCard(
          product: product,
          onTap: () => onTap(product),
        );
      },
    );
  }
}

class _SearchError extends StatelessWidget {
  final VoidCallback onRetry;

  const _SearchError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return DSStateView.error(
      body: 'Something went wrong while searching.',
      onCtaPressed: onRetry,
    );
  }
}
