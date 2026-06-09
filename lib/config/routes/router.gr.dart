// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

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
    List<PageRouteInfo>? children,
  }) : super(
         PaywallRoute.name,
         args: PaywallRouteArgs(key: key, dismissible: dismissible),
         initialChildren: children,
       );

  static const String name = 'PaywallRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PaywallRouteArgs>(
        orElse: () => const PaywallRouteArgs(),
      );
      return PaywallPage(key: args.key, dismissible: args.dismissible);
    },
  );
}

class PaywallRouteArgs {
  const PaywallRouteArgs({this.key, this.dismissible = true});

  final Key? key;

  final bool dismissible;

  @override
  String toString() {
    return 'PaywallRouteArgs{key: $key, dismissible: $dismissible}';
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
class ScannerRoute extends PageRouteInfo<void> {
  const ScannerRoute({List<PageRouteInfo>? children})
    : super(ScannerRoute.name, initialChildren: children);

  static const String name = 'ScannerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ScannerPage();
    },
  );
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

/// generated route for
/// [SuccessPage]
class SuccessRoute extends PageRouteInfo<SuccessRouteArgs> {
  SuccessRoute({
    Key? key,
    required CatSummary? summary,
    required void Function(BuildContext) onStart,
    List<PageRouteInfo>? children,
  }) : super(
         SuccessRoute.name,
         args: SuccessRouteArgs(key: key, summary: summary, onStart: onStart),
         initialChildren: children,
       );

  static const String name = 'SuccessRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SuccessRouteArgs>();
      return SuccessPage(
        key: args.key,
        summary: args.summary,
        onStart: args.onStart,
      );
    },
  );
}

class SuccessRouteArgs {
  const SuccessRouteArgs({
    this.key,
    required this.summary,
    required this.onStart,
  });

  final Key? key;

  final CatSummary? summary;

  final void Function(BuildContext) onStart;

  @override
  String toString() {
    return 'SuccessRouteArgs{key: $key, summary: $summary, onStart: $onStart}';
  }
}
