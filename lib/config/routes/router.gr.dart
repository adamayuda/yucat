// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [AnalyzePage]
class AnalyzeRoute extends PageRouteInfo<AnalyzeRouteArgs> {
  AnalyzeRoute({
    Key? key,
    required CatSummary summary,
    required void Function(BuildContext) onStart,
    List<PageRouteInfo>? children,
  }) : super(
         AnalyzeRoute.name,
         args: AnalyzeRouteArgs(key: key, summary: summary, onStart: onStart),
         initialChildren: children,
       );

  static const String name = 'AnalyzeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AnalyzeRouteArgs>();
      return AnalyzePage(
        key: args.key,
        summary: args.summary,
        onStart: args.onStart,
      );
    },
  );
}

class AnalyzeRouteArgs {
  const AnalyzeRouteArgs({
    this.key,
    required this.summary,
    required this.onStart,
  });

  final Key? key;

  final CatSummary summary;

  final void Function(BuildContext) onStart;

  @override
  String toString() {
    return 'AnalyzeRouteArgs{key: $key, summary: $summary, onStart: $onStart}';
  }
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
/// [CurrentFoodPage]
class CurrentFoodRoute extends PageRouteInfo<CurrentFoodRouteArgs> {
  CurrentFoodRoute({
    Key? key,
    required CatSummary summary,
    required void Function(BuildContext) onStart,
    List<PageRouteInfo>? children,
  }) : super(
         CurrentFoodRoute.name,
         args: CurrentFoodRouteArgs(
           key: key,
           summary: summary,
           onStart: onStart,
         ),
         initialChildren: children,
       );

  static const String name = 'CurrentFoodRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CurrentFoodRouteArgs>();
      return CurrentFoodPage(
        key: args.key,
        summary: args.summary,
        onStart: args.onStart,
      );
    },
  );
}

class CurrentFoodRouteArgs {
  const CurrentFoodRouteArgs({
    this.key,
    required this.summary,
    required this.onStart,
  });

  final Key? key;

  final CatSummary summary;

  final void Function(BuildContext) onStart;

  @override
  String toString() {
    return 'CurrentFoodRouteArgs{key: $key, summary: $summary, onStart: $onStart}';
  }
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
/// [ResultPage]
class ResultRoute extends PageRouteInfo<ResultRouteArgs> {
  ResultRoute({
    Key? key,
    required CatSummary summary,
    required CatNarrative? narrative,
    required void Function(BuildContext) onStart,
    List<PageRouteInfo>? children,
  }) : super(
         ResultRoute.name,
         args: ResultRouteArgs(
           key: key,
           summary: summary,
           narrative: narrative,
           onStart: onStart,
         ),
         initialChildren: children,
       );

  static const String name = 'ResultRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ResultRouteArgs>();
      return ResultPage(
        key: args.key,
        summary: args.summary,
        narrative: args.narrative,
        onStart: args.onStart,
      );
    },
  );
}

class ResultRouteArgs {
  const ResultRouteArgs({
    this.key,
    required this.summary,
    required this.narrative,
    required this.onStart,
  });

  final Key? key;

  final CatSummary summary;

  final CatNarrative? narrative;

  final void Function(BuildContext) onStart;

  @override
  String toString() {
    return 'ResultRouteArgs{key: $key, summary: $summary, narrative: $narrative, onStart: $onStart}';
  }
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
    void Function(String, String)? onCaptured,
    List<PageRouteInfo>? children,
  }) : super(
         ScannerRoute.name,
         args: ScannerRouteArgs(key: key, onCaptured: onCaptured),
         initialChildren: children,
       );

  static const String name = 'ScannerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ScannerRouteArgs>(
        orElse: () => const ScannerRouteArgs(),
      );
      return ScannerPage(key: args.key, onCaptured: args.onCaptured);
    },
  );
}

class ScannerRouteArgs {
  const ScannerRouteArgs({this.key, this.onCaptured});

  final Key? key;

  final void Function(String, String)? onCaptured;

  @override
  String toString() {
    return 'ScannerRouteArgs{key: $key, onCaptured: $onCaptured}';
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
