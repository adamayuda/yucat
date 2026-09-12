// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [ArticleDetailPage]
class ArticleDetailRoute extends PageRouteInfo<ArticleDetailRouteArgs> {
  ArticleDetailRoute({
    Key? key,
    required ArticleDisplayModel article,
    List<PageRouteInfo>? children,
  }) : super(
         ArticleDetailRoute.name,
         args: ArticleDetailRouteArgs(key: key, article: article),
         initialChildren: children,
       );

  static const String name = 'ArticleDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ArticleDetailRouteArgs>();
      return ArticleDetailPage(key: args.key, article: args.article);
    },
  );
}

class ArticleDetailRouteArgs {
  const ArticleDetailRouteArgs({this.key, required this.article});

  final Key? key;

  final ArticleDisplayModel article;

  @override
  String toString() {
    return 'ArticleDetailRouteArgs{key: $key, article: $article}';
  }
}

/// generated route for
/// [ArticlesPage]
class ArticlesRoute extends PageRouteInfo<void> {
  const ArticlesRoute({List<PageRouteInfo>? children})
    : super(ArticlesRoute.name, initialChildren: children);

  static const String name = 'ArticlesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ArticlesPage();
    },
  );
}

/// generated route for
/// [CatDetailPage]
class CatDetailRoute extends PageRouteInfo<CatDetailRouteArgs> {
  CatDetailRoute({
    Key? key,
    required CatModel cat,
    List<PageRouteInfo>? children,
  }) : super(
         CatDetailRoute.name,
         args: CatDetailRouteArgs(key: key, cat: cat),
         initialChildren: children,
       );

  static const String name = 'CatDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CatDetailRouteArgs>();
      return CatDetailPage(key: args.key, cat: args.cat);
    },
  );
}

class CatDetailRouteArgs {
  const CatDetailRouteArgs({this.key, required this.cat});

  final Key? key;

  final CatModel cat;

  @override
  String toString() {
    return 'CatDetailRouteArgs{key: $key, cat: $cat}';
  }
}

/// generated route for
/// [CatListingPage]
class CatListingRoute extends PageRouteInfo<void> {
  const CatListingRoute({List<PageRouteInfo>? children})
    : super(CatListingRoute.name, initialChildren: children);

  static const String name = 'CatListingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CatListingPage();
    },
  );
}

/// generated route for
/// [CreateCatPage]
class CreateCatRoute extends PageRouteInfo<CreateCatRouteArgs> {
  CreateCatRoute({
    Key? key,
    CatModel? cat,
    String? seededName,
    String? seededPhotoPath,
    void Function(BuildContext, CatSummary)? onCreated,
    List<PageRouteInfo>? children,
  }) : super(
         CreateCatRoute.name,
         args: CreateCatRouteArgs(
           key: key,
           cat: cat,
           seededName: seededName,
           seededPhotoPath: seededPhotoPath,
           onCreated: onCreated,
         ),
         initialChildren: children,
       );

  static const String name = 'CreateCatRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreateCatRouteArgs>(
        orElse: () => const CreateCatRouteArgs(),
      );
      return CreateCatPage(
        key: args.key,
        cat: args.cat,
        seededName: args.seededName,
        seededPhotoPath: args.seededPhotoPath,
        onCreated: args.onCreated,
      );
    },
  );
}

class CreateCatRouteArgs {
  const CreateCatRouteArgs({
    this.key,
    this.cat,
    this.seededName,
    this.seededPhotoPath,
    this.onCreated,
  });

  final Key? key;

  final CatModel? cat;

  final String? seededName;

  final String? seededPhotoPath;

  final void Function(BuildContext, CatSummary)? onCreated;

  @override
  String toString() {
    return 'CreateCatRouteArgs{key: $key, cat: $cat, seededName: $seededName, seededPhotoPath: $seededPhotoPath, onCreated: $onCreated}';
  }
}

/// generated route for
/// [FoodGuideDetailPage]
class FoodGuideDetailRoute extends PageRouteInfo<FoodGuideDetailRouteArgs> {
  FoodGuideDetailRoute({
    Key? key,
    required FoodGuideDisplayModel item,
    List<PageRouteInfo>? children,
  }) : super(
         FoodGuideDetailRoute.name,
         args: FoodGuideDetailRouteArgs(key: key, item: item),
         initialChildren: children,
       );

  static const String name = 'FoodGuideDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FoodGuideDetailRouteArgs>();
      return FoodGuideDetailPage(key: args.key, item: args.item);
    },
  );
}

class FoodGuideDetailRouteArgs {
  const FoodGuideDetailRouteArgs({this.key, required this.item});

  final Key? key;

  final FoodGuideDisplayModel item;

  @override
  String toString() {
    return 'FoodGuideDetailRouteArgs{key: $key, item: $item}';
  }
}

/// generated route for
/// [FoodGuidePage]
class FoodGuideRoute extends PageRouteInfo<void> {
  const FoodGuideRoute({List<PageRouteInfo>? children})
    : super(FoodGuideRoute.name, initialChildren: children);

  static const String name = 'FoodGuideRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FoodGuidePage();
    },
  );
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [LitterDetailPage]
class LitterDetailRoute extends PageRouteInfo<LitterDetailRouteArgs> {
  LitterDetailRoute({
    Key? key,
    LitterDisplayModel? litter,
    List<PageRouteInfo>? children,
  }) : super(
         LitterDetailRoute.name,
         args: LitterDetailRouteArgs(key: key, litter: litter),
         initialChildren: children,
       );

  static const String name = 'LitterDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LitterDetailRouteArgs>(
        orElse: () => const LitterDetailRouteArgs(),
      );
      return LitterDetailPage(key: args.key, litter: args.litter);
    },
  );
}

class LitterDetailRouteArgs {
  const LitterDetailRouteArgs({this.key, this.litter});

  final Key? key;

  final LitterDisplayModel? litter;

  @override
  String toString() {
    return 'LitterDetailRouteArgs{key: $key, litter: $litter}';
  }
}

/// generated route for
/// [MainPage]
class MainRoute extends PageRouteInfo<void> {
  const MainRoute({List<PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainPage();
    },
  );
}

/// generated route for
/// [OnBoardingPage]
class OnBoardingRoute extends PageRouteInfo<void> {
  const OnBoardingRoute({List<PageRouteInfo>? children})
    : super(OnBoardingRoute.name, initialChildren: children);

  static const String name = 'OnBoardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OnBoardingPage();
    },
  );
}

/// generated route for
/// [PaywallPage]
class PaywallRoute extends PageRouteInfo<PaywallRouteArgs> {
  PaywallRoute({
    Key? key,
    bool dismissible = true,
    String trigger = 'manual',
    List<PageRouteInfo>? children,
  }) : super(
         PaywallRoute.name,
         args: PaywallRouteArgs(
           key: key,
           dismissible: dismissible,
           trigger: trigger,
         ),
         initialChildren: children,
       );

  static const String name = 'PaywallRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PaywallRouteArgs>(
        orElse: () => const PaywallRouteArgs(),
      );
      return PaywallPage(
        key: args.key,
        dismissible: args.dismissible,
        trigger: args.trigger,
      );
    },
  );
}

class PaywallRouteArgs {
  const PaywallRouteArgs({
    this.key,
    this.dismissible = true,
    this.trigger = 'manual',
  });

  final Key? key;

  final bool dismissible;

  final String trigger;

  @override
  String toString() {
    return 'PaywallRouteArgs{key: $key, dismissible: $dismissible, trigger: $trigger}';
  }
}

/// generated route for
/// [ProductDetailPage]
class ProductDetailRoute extends PageRouteInfo<ProductDetailRouteArgs> {
  ProductDetailRoute({
    Key? key,
    ProductDisplayModel? product,
    List<PageRouteInfo>? children,
  }) : super(
         ProductDetailRoute.name,
         args: ProductDetailRouteArgs(key: key, product: product),
         initialChildren: children,
       );

  static const String name = 'ProductDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProductDetailRouteArgs>(
        orElse: () => const ProductDetailRouteArgs(),
      );
      return ProductDetailPage(key: args.key, product: args.product);
    },
  );
}

class ProductDetailRouteArgs {
  const ProductDetailRouteArgs({this.key, this.product});

  final Key? key;

  final ProductDisplayModel? product;

  @override
  String toString() {
    return 'ProductDetailRouteArgs{key: $key, product: $product}';
  }
}

/// generated route for
/// [ProductListingPage]
class ProductListingRoute extends PageRouteInfo<ProductListingRouteArgs> {
  ProductListingRoute({
    Key? key,
    required String brandName,
    List<PageRouteInfo>? children,
  }) : super(
         ProductListingRoute.name,
         args: ProductListingRouteArgs(key: key, brandName: brandName),
         initialChildren: children,
       );

  static const String name = 'ProductListingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProductListingRouteArgs>();
      return ProductListingPage(key: args.key, brandName: args.brandName);
    },
  );
}

class ProductListingRouteArgs {
  const ProductListingRouteArgs({this.key, required this.brandName});

  final Key? key;

  final String brandName;

  @override
  String toString() {
    return 'ProductListingRouteArgs{key: $key, brandName: $brandName}';
  }
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfilePage();
    },
  );
}

/// generated route for
/// [RecipeDetailPage]
class RecipeDetailRoute extends PageRouteInfo<RecipeDetailRouteArgs> {
  RecipeDetailRoute({
    Key? key,
    required RecipeDisplayModel recipe,
    List<PageRouteInfo>? children,
  }) : super(
         RecipeDetailRoute.name,
         args: RecipeDetailRouteArgs(key: key, recipe: recipe),
         initialChildren: children,
       );

  static const String name = 'RecipeDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RecipeDetailRouteArgs>();
      return RecipeDetailPage(key: args.key, recipe: args.recipe);
    },
  );
}

class RecipeDetailRouteArgs {
  const RecipeDetailRouteArgs({this.key, required this.recipe});

  final Key? key;

  final RecipeDisplayModel recipe;

  @override
  String toString() {
    return 'RecipeDetailRouteArgs{key: $key, recipe: $recipe}';
  }
}

/// generated route for
/// [RecipesPage]
class RecipesRoute extends PageRouteInfo<void> {
  const RecipesRoute({List<PageRouteInfo>? children})
    : super(RecipesRoute.name, initialChildren: children);

  static const String name = 'RecipesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RecipesPage();
    },
  );
}

/// generated route for
/// [SavedProductsPage]
class SavedProductsRoute extends PageRouteInfo<void> {
  const SavedProductsRoute({List<PageRouteInfo>? children})
    : super(SavedProductsRoute.name, initialChildren: children);

  static const String name = 'SavedProductsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SavedProductsPage();
    },
  );
}

/// generated route for
/// [ScanHistoryPage]
class ScanHistoryRoute extends PageRouteInfo<void> {
  const ScanHistoryRoute({List<PageRouteInfo>? children})
    : super(ScanHistoryRoute.name, initialChildren: children);

  static const String name = 'ScanHistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ScanHistoryPage();
    },
  );
}

/// generated route for
/// [ScannerPage]
class ScannerRoute extends PageRouteInfo<ScannerRouteArgs> {
  ScannerRoute({
    Key? key,
    ScanMode mode = ScanMode.pack,
    LabelTarget? labelTarget,
    List<PageRouteInfo>? children,
  }) : super(
         ScannerRoute.name,
         args: ScannerRouteArgs(key: key, mode: mode, labelTarget: labelTarget),
         initialChildren: children,
       );

  static const String name = 'ScannerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ScannerRouteArgs>(
        orElse: () => const ScannerRouteArgs(),
      );
      return ScannerPage(
        key: args.key,
        mode: args.mode,
        labelTarget: args.labelTarget,
      );
    },
  );
}

class ScannerRouteArgs {
  const ScannerRouteArgs({
    this.key,
    this.mode = ScanMode.pack,
    this.labelTarget,
  });

  final Key? key;

  final ScanMode mode;

  final LabelTarget? labelTarget;

  @override
  String toString() {
    return 'ScannerRouteArgs{key: $key, mode: $mode, labelTarget: $labelTarget}';
  }
}

/// generated route for
/// [SearchPage]
class SearchRoute extends PageRouteInfo<void> {
  const SearchRoute({List<PageRouteInfo>? children})
    : super(SearchRoute.name, initialChildren: children);

  static const String name = 'SearchRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SearchPage();
    },
  );
}

/// generated route for
/// [SplashPage]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashPage();
    },
  );
}
