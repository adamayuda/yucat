import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat_listing/mappers/cat_entity_to_model_mapper.dart';
import 'package:yucat/features/home/bloc/home_bloc.dart';
import 'package:yucat/features/home/bloc/home_event.dart';
import 'package:yucat/features/home/bloc/home_state.dart';
import 'package:yucat/features/home/widgets/home_dashboard_page.dart';
import 'package:yucat/features/home/widgets/home_loading_page.dart';
import 'package:yucat/features/home/widgets/home_skeleton.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/presentation/components/ds_state_view.dart';
import 'package:yucat/service_locator.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  late HomeBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<HomeBloc>();
    _bloc.add(HomeInitialEvent());
  }

  // NOTE: HomeBloc's lifecycle is owned by the root MultiBlocProvider in
  // main.dart — this page must NOT close it. Closing it here left a dead bloc
  // in the shared provider, so re-mounting the Home tab threw "Cannot add new
  // events after calling close" from initState.

  void _openScanner() {
    context.router.push(const ScannerRoute());
  }

  Future<void> _openProduct(ProductDisplayModel product) async {
    sl<LogEventUsecase>().call(
      eventName: 'Home Saved Product Tapped',
      properties: {
        'product_name': product.name,
        'product_brand': product.brand,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    await context.router.push(ProductDetailRoute(product: product));
    // A bookmark may have been toggled on the detail page — refresh the
    // preview so an unsaved item disappears on return.
    _bloc.add(HomeInitialEvent());
  }

  void _openSavedProducts(int count) {
    sl<LogEventUsecase>().call(
      eventName: 'Home See All Saved Tapped',
      properties: {
        'count': count,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    context.router.push(const SavedProductsRoute());
  }

  void _openCatDetail(CatEntity cat) {
    sl<LogEventUsecase>().call(
      eventName: 'Home Cat Snapshot Tapped',
      properties: {
        'cat_id': cat.id,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    final model = sl<CatEntityToModelMapper>()(cat);
    context.router.push(CatDetailRoute(cat: model));
  }

  void _onActiveCatChanged(CatEntity cat) {
    sl<LogEventUsecase>().call(
      eventName: 'Home Active Cat Changed',
      properties: {
        'cat_id': cat.id,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  void _openCreateCat() {
    context.router.push(CreateCatRoute());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: _bloc,
      builder: (context, state) => _onStateChangeBuilder(state),
    );
  }

  Widget _onStateChangeBuilder(HomeState state) {
    switch (state) {
      case HomeLoadingState():
        return Scaffold(
          backgroundColor: DSColors.tintLavender,
          body: const HomeSkeleton(),
        );
      case HomeScanningState():
        return Scaffold(
          backgroundColor: DSColors.tintLavender,
          body: const HomeLoadingWidget(),
        );
      case HomeLoadedState(:final cats, :final savedProducts):
        return HomeDashboardPage(
          cats: cats,
          savedProducts: savedProducts,
          onScanTap: _openScanner,
          onCatTap: _openCatDetail,
          onProductTap: _openProduct,
          onSeeAllSaved: () => _openSavedProducts(savedProducts.length),
          onCreateCat: _openCreateCat,
          onActiveCatChanged: _onActiveCatChanged,
        );
      case HomeErrorState():
        return Scaffold(
          backgroundColor: DSColors.tintLavender,
          body: SafeArea(
            child: DSStateView.error(
              body: state.message,
              onCtaPressed: () => _bloc.add(HomeInitialEvent()),
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
