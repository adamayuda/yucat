// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

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
class CreateCatRoute extends PageRouteInfo<void> {
  const CreateCatRoute({List<PageRouteInfo>? children})
    : super(CreateCatRoute.name, initialChildren: children);

  static const String name = 'CreateCatRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CreateCatPage();
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
class PaywallRoute extends PageRouteInfo<void> {
  const PaywallRoute({List<PageRouteInfo>? children})
    : super(PaywallRoute.name, initialChildren: children);

  static const String name = 'PaywallRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PaywallPage();
    },
  );
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
