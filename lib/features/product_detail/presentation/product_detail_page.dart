import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/domain/usecases/get_cats_usecase.dart';
import 'package:yucat/features/product_detail/presentation/bloc/product_detail_bloc.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/widgets/analysis_card.dart';
import 'package:yucat/features/product_detail/presentation/widgets/cat_assessment_card.dart';
import 'package:yucat/features/product_detail/presentation/widgets/nutrition_grid_card.dart';
import 'package:yucat/features/product_detail/presentation/widgets/product_hero_card.dart';
import 'package:yucat/presentation/components/ds_app_bar.dart';
import 'package:yucat/presentation/components/ds_state_view.dart';
import 'package:yucat/presentation/widgets/app_loading_widget.dart';
import 'package:yucat/service_locator.dart';

@RoutePage()
class ProductDetailPage extends StatefulWidget {
  final ProductDisplayModel? product;

  const ProductDetailPage({super.key, this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late ProductDetailBloc _bloc;
  late GetCatsUsecase _getCatsUsecase;
  late CurrentUserUsecase _currentUserUsecase;
  Future<List<CatEntity>>? _catsFuture;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<ProductDetailBloc>();
    _bloc.add(ProductDetailInitialEvent(product: widget.product));
    _getCatsUsecase = sl<GetCatsUsecase>();
    _currentUserUsecase = sl<CurrentUserUsecase>();
    _refreshCats();
  }

  void _refreshCats() {
    final user = _currentUserUsecase();
    if (user != null) {
      setState(() {
        _catsFuture = _getCatsUsecase(userId: user.uid);
      });
    }
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
              onBack: () => Navigator.of(context).pop(),
              actions: [
                _CircleIconButton(
                  icon: Icons.bookmark_border_rounded,
                  // TODO: wire saved-products bookmark
                  onPressed: () {},
                ),
                _CircleIconButton(
                  icon: Icons.more_horiz_rounded,
                  // TODO: wire overflow menu (report, share)
                  onPressed: () {},
                ),
              ],
            ),
            Expanded(
              child: BlocBuilder<ProductDetailBloc, ProductDetailState>(
                bloc: _bloc,
                buildWhen: (previous, current) => previous != current,
                builder: (context, state) => switch (state) {
                  ProductDetailLoadingState() => const AppLoadingWidget(),
                  ProductDetailLoadedState(:final product) =>
                    _LoadedBody(
                      product: product,
                      catsFuture: _catsFuture,
                      onCreateCat: _onCreateCat,
                    ),
                  ProductDetailErrorState() => const _ErrorBody(),
                  _ => const SizedBox.shrink(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onCreateCat() async {
    await context.router.push(CreateCatRoute());
    _refreshCats();
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DSColors.surfaceCard,
      shape: const CircleBorder(),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: DSColors.surfaceCard,
          shape: BoxShape.circle,
          boxShadow: DSShadows.e1,
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, color: DSColors.inkPrimary, size: 18),
          ),
        ),
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  final ProductDisplayModel product;
  final Future<List<CatEntity>>? catsFuture;
  final Future<void> Function() onCreateCat;

  const _LoadedBody({
    required this.product,
    required this.catsFuture,
    required this.onCreateCat,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom + DSDimens.size3xl;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        DSDimens.sizeL,
        DSDimens.sizeXs,
        DSDimens.sizeL,
        bottomInset,
      ),
      children: [
        ProductHeroCard(product: product),
        const SizedBox(height: DSDimens.sizeL),
        AnalysisCard(product: product),
        const SizedBox(height: DSDimens.sizeL),
        FutureBuilder<List<CatEntity>>(
          future: catsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: DSDimens.sizeL),
                child: AppLoadingWidget(),
              );
            }
            return CatAssessmentSection(
              cats: snapshot.data ?? const [],
              product: product,
              onCreateCat: () => onCreateCat(),
            );
          },
        ),
        const SizedBox(height: DSDimens.sizeL),
        NutritionGridCard(product: product),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody();

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => DSStateView.error(
        body: 'Could not load this product.',
        ctaLabel: 'Go back',
        onCtaPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
