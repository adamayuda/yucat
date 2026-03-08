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
import 'package:yucat/features/product_detail/presentation/utils/cat_product_assessment.dart';
import 'package:yucat/presentation/top_app_bar/top_app_bar.dart';
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
  void dispose() {
    // Don't close the bloc here - it's provided at the app level
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailBloc, ProductDetailState>(
      bloc: _bloc,
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) => _onStateChangeBuilder(state),
    );
  }

  Widget _onStateChangeBuilder(ProductDetailState state) {
    switch (state) {
      case ProductDetailLoadingState():
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: TopAppBar(title: ''),
          ),
          body: const AppLoadingWidget(),
        );
      case ProductDetailLoadedState():
        return Scaffold(
          backgroundColor: DSColors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: TopAppBar(title: ''),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                _buildProductImage(state.product),

                SizedBox(height: DSDimens.sizeM),

                // Product Name and Brand
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: DSDimens.sizeS),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.product.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: DSDimens.sizeXxxs),
                      Text(
                        state.product.brand,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: DSColors.darkGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: DSDimens.sizeM),

                // Health Score Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: DSDimens.sizeS),
                  child: _buildHealthScore(state.product),
                ),

                SizedBox(height: DSDimens.sizeXs),

                // Nutritional Information Cards
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: DSDimens.sizeS),
                  child: _buildNutritionalCards(state.product),
                ),

                SizedBox(height: DSDimens.sizeM),

                // My Cat's Score Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: DSDimens.sizeS),
                  child: _buildMyCatsScoreSection(state.product),
                ),

                SizedBox(height: DSDimens.sizeM),

                // Results Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: DSDimens.sizeS),
                  child: _buildResultsSection(state.product),
                ),

                SizedBox(height: DSDimens.sizeXl),
              ],
            ),
          ),
        );
      case ProductDetailErrorState():
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: TopAppBar(title: ''),
          ),
          body: const Center(child: Text('Error loading product')),
        );
      default:
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: TopAppBar(title: ''),
          ),
          body: const Center(child: Text('Unknown state')),
        );
    }
  }

  Widget _buildProductImage(ProductDisplayModel product) {
    final hasValidImage =
        product.imageUrl != null && product.imageUrl!.isNotEmpty;
    return Container(
      width: double.infinity,
      height: 300,
      color: DSColors.white,
      child: hasValidImage
          ? Image.network(product.imageUrl!, fit: BoxFit.contain)
          : Center(
              child: Icon(Icons.image, size: 100, color: DSColors.darkGrey),
            ),
    );
  }

  Widget _buildNutritionalCards(ProductDisplayModel product) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DSDimens.sizeXxxs,
        vertical: DSDimens.sizeXs,
      ),
      decoration: BoxDecoration(
        color: DSColors.white,
        border: Border.all(color: DSColors.lightGrey),
        borderRadius: BorderRadius.circular(DSDimens.sizeS),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _NutritionCard(
                iconAsset: 'assets/images/Icons/egg.png',
                value: '${product.protein.toStringAsFixed(1)}%',
                label: 'Protein',
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: DSColors.lightGrey),
            Expanded(
              child: _NutritionCard(
                iconAsset: 'assets/images/Icons/water.png',
                value: '${product.moisture.toStringAsFixed(1)}%',
                label: 'Moisture',
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: DSColors.lightGrey),
            Expanded(
              child: _NutritionCard(
                iconAsset: 'assets/images/Icons/butter.png',
                value: '${product.fat.toStringAsFixed(1)}%',
                label: 'Fat',
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: DSColors.lightGrey),
            Expanded(
              child: _NutritionCard(
                iconAsset: 'assets/images/Icons/fire.png',
                value: '${product.fiber.toStringAsFixed(1)}%',
                label: 'Fiber',
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: DSColors.lightGrey),
            Expanded(
              child: _NutritionCard(
                iconAsset: 'assets/images/Icons/wheat.png',
                value: '${product.carbs.toStringAsFixed(1)}%',
                label: 'Carbs',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScore(ProductDisplayModel product) {
    final progress = product.score / 100.0;

    return Container(
      padding: EdgeInsets.all(DSDimens.sizeS),
      decoration: BoxDecoration(
        color: DSColors.white,
        border: Border.all(color: DSColors.lightGrey),
        borderRadius: BorderRadius.circular(DSDimens.sizeS),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/Icons/heart.png',
            width: DSDimens.sizeXxl,
            height: DSDimens.sizeXxl,
            fit: BoxFit.contain,
          ),
          SizedBox(width: DSDimens.sizeXxs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Health Score',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      product.scoreDisplay,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: DSDimens.sizeXxs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(DSDimens.sizeXxs),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: DSColors.inputLightGrey,
                    valueColor: AlwaysStoppedAnimation<Color>(DSColors.green),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyCatsScoreSection(ProductDisplayModel product) {
    final user = _currentUserUsecase();

    if (user == null) {
      return const SizedBox.shrink();
    }

    // Ensure future is initialized
    _catsFuture ??= _getCatsUsecase(userId: user.uid);

    return FutureBuilder<List<CatEntity>>(
      future: _catsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: EdgeInsets.all(DSDimens.sizeS),
            decoration: BoxDecoration(
              color: DSColors.white,
              border: Border.all(color: DSColors.lightGrey),
              borderRadius: BorderRadius.circular(DSDimens.sizeS),
            ),
            child: const AppLoadingWidget(),
          );
        }

        final cats = snapshot.data ?? [];
        final hasCats = cats.isNotEmpty;

        if (!hasCats) {
          return Container(
            padding: EdgeInsets.all(DSDimens.sizeS),
            decoration: BoxDecoration(
              color: DSColors.white,
              border: Border.all(color: DSColors.lightGrey),
              borderRadius: BorderRadius.circular(DSDimens.sizeS),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Cat\'s Score',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: DSDimens.sizeXxs),
                Text(
                  'Create a cat profile to see personalized scores',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: DSColors.darkGrey),
                ),
                SizedBox(height: DSDimens.sizeS),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await context.router.push(CreateCatRoute());
                      // Refresh cats list when returning from create cat page
                      _refreshCats();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DSColors.primary,
                      foregroundColor: DSColors.white,
                      padding: EdgeInsets.symmetric(vertical: DSDimens.sizeS),
                    ),
                    child: const Text('New Cat Profile'),
                  ),
                ),
              ],
            ),
          );
        }

        // Show per-cat analysis if cats exist
        return Container(
          // padding: EdgeInsets.all(DSDimens.sizeS),
          decoration: BoxDecoration(
            color: DSColors.white,
            border: Border.all(color: DSColors.lightGrey),
            borderRadius: BorderRadius.circular(DSDimens.sizeS),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...cats.map((cat) {
                final assessment = evaluateCatProduct(cat, product);
                final hasPros = assessment.pros.isNotEmpty;
                final hasCons = assessment.cons.isNotEmpty;

                return Padding(
                  padding: EdgeInsets.only(top: DSDimens.sizeS),
                  child: Container(
                    padding: EdgeInsets.all(DSDimens.sizeS),
                    decoration: BoxDecoration(
                      color: DSColors.white,
                      borderRadius: BorderRadius.circular(DSDimens.sizeS),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cat profile photo and name
                        Row(
                          children: [
                            // Profile rphoto
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: DSColors.lightGrey,
                              backgroundImage:
                                  cat.profileImageUrl != null &&
                                      cat.profileImageUrl!.isNotEmpty
                                  ? NetworkImage(cat.profileImageUrl!)
                                  : null,
                              child:
                                  cat.profileImageUrl == null ||
                                      cat.profileImageUrl!.isEmpty
                                  ? Icon(
                                      Icons.pets,
                                      color: DSColors.darkGrey,
                                      size: 24,
                                    )
                                  : null,
                            ),
                            SizedBox(width: DSDimens.sizeS),
                            // Cat name
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.name,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  if (cat.ageGroup != null) ...[
                                    SizedBox(height: DSDimens.sizeXxxs / 2),
                                    Text(
                                      switch (cat.ageGroup) {
                                        'kitten' => 'Kitten',
                                        'adult' => 'Adult',
                                        'senior' => 'Senior',
                                        _ => cat.ageGroup!,
                                      },
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: DSColors.darkGrey),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (hasPros || hasCons) ...[
                          SizedBox(height: DSDimens.sizeXs),
                          if (hasPros)
                            _ResultItem(
                              label: 'Pros',
                              items: assessment.pros,
                              value: '${assessment.pros.length}',
                              indicatorColor: DSColors.green,
                              iconAsset: 'assets/images/Icons/green.png',
                            ),
                          if (hasCons) ...[
                            SizedBox(height: DSDimens.sizeXxs),
                            _ResultItem(
                              label: 'Cons',
                              items: assessment.cons,
                              value: '${assessment.cons.length}',
                              indicatorColor: Colors.orange,
                              iconAsset: 'assets/images/Icons/red.png',
                            ),
                          ],
                        ] else ...[
                          SizedBox(height: DSDimens.sizeXs),
                          Text(
                            'No strong age-based pros or cons for this cat.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: DSColors.darkGrey),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultsSection(ProductDisplayModel product) {
    final hasPros = product.pros.isNotEmpty;
    final hasCons = product.cons.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Analysis',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: DSDimens.sizeXxs),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 0,
            vertical: DSDimens.sizeXs,
          ),
          decoration: BoxDecoration(
            color: DSColors.white,
            border: Border.all(color: DSColors.lightGrey),
            borderRadius: BorderRadius.circular(DSDimens.sizeS),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasPros) ...[
                ...product.pros.map(
                  (item) => Padding(
                    padding: EdgeInsets.only(
                      left: DSDimens.sizeXxs,
                      top: DSDimens.sizeXxs / 4,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/Icons/green.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                        ),
                        Expanded(
                          child: Text(
                            item,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: DSColors.darkGrey,
                                  fontSize: 12,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (hasCons) ...[
                if (hasPros) SizedBox(height: DSDimens.sizeXxs),
                ...product.cons.map(
                  (item) => Padding(
                    padding: EdgeInsets.only(
                      left: DSDimens.sizeXxs,
                      top: DSDimens.sizeXxs / 4,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: DSDimens.sizeXxs / 2),
                          child: Image.asset(
                            'assets/images/Icons/red.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: DSColors.darkGrey,
                                  fontSize: 12,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final String iconAsset;
  final String value;
  final String label;

  const _NutritionCard({
    required this.iconAsset,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(iconAsset, width: 32, height: 32, fit: BoxFit.contain),
        SizedBox(height: DSDimens.sizeXxxs),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: DSDimens.sizeXxxs),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: DSColors.darkGrey),
        ),
      ],
    );
  }
}

class _ResultItem extends StatelessWidget {
  final String label;
  final List<String> items;
  final String value;
  final Color indicatorColor;
  final String? iconAsset;

  const _ResultItem({
    required this.label,
    required this.items,
    required this.value,
    required this.indicatorColor,
    this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (items.isNotEmpty) ...[
                ...items.map(
                  (item) => Padding(
                    padding: EdgeInsets.only(
                      left: DSDimens.sizeXxs,
                      top: DSDimens.sizeXxs / 4,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (iconAsset != null)
                          Padding(
                            padding: EdgeInsets.only(
                              right: DSDimens.sizeXxs / 2,
                            ),
                            child: Image.asset(
                              iconAsset!,
                              width: 32,
                              height: 32,
                              fit: BoxFit.contain,
                            ),
                          )
                        else
                          Text(
                            '• ',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: DSColors.darkGrey,
                                  fontSize: 12,
                                ),
                          ),
                        Expanded(
                          child: Text(
                            item,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: DSColors.darkGrey,
                                  fontSize: 12,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
